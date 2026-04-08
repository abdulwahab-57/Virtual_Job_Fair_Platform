class CareerOfficer::MeetingsController < CareerOfficer::BaseController
  before_action :set_zoom_access_token, only: [ :index, :new, :create ]

  def new
    @header_text = "Schedule Meeting"
    @meeting = Meeting.new
    @meeting.invitees = []
    # Add a virtual attribute to handle display
    @meeting.invitees_list = @meeting.invitees.map(&:email).join(", ")
  end

  def create
    if @access_token.blank?
      redirect_to career_officer_meetings_path, alert: "Zoom is not connected." and return
    end

    @meeting = current_user.meetings.new(meeting_params.except(:start_date, :start_hour, :start_minute, :am_pm, :duration_hr, :duration_min, :invitees))

    # Compose start_time
    begin
      hour = meeting_params[:start_hour].to_i
      hour += 12 if meeting_params[:am_pm] == "PM" && hour != 12
      hour = 0 if meeting_params[:am_pm] == "AM" && hour == 12
      start_time = DateTime.parse("#{meeting_params[:start_date]} #{hour}:#{meeting_params[:start_minute]}:00")
    rescue ArgumentError => e
      flash.now[:alert] = "Invalid date or time format: #{e.message}"
      render :new, status: :unprocessable_entity and return
    end

    duration = meeting_params[:duration_hr].to_i * 60 + meeting_params[:duration_min].to_i

    # Prepare Zoom API payload
    zoom_params = {
      topic: meeting_params[:topic],
      type: 2,
      start_time: start_time.strftime("%Y-%m-%dT%H:%M:%S"),
      duration: duration,
      timezone: "UTC",
      settings: {
        participant_video: true,
        mute_upon_entry: true
      }
    }

    # Handle invitees
    invitees = meeting_params[:invitees_list].to_s.split(/[\s,;]+/).map(&:strip).reject(&:empty?)
    invitees << current_user.email unless invitees.include?(current_user.email)
    zoom_params[:settings][:meeting_invitees] = invitees.map { |email| { email: email } }

    zoom_client = Zoom::Client::OAuth.new(access_token: @access_token, timeout: 15)

    begin
      user = zoom_client.user_get(id: "me")
      response= zoom_client.meeting_create(user_id: user["id"], **zoom_params)
      Rails.logger.info("Meeting Respose Object: #{response}")

      @meeting.start_time = start_time
      @meeting.duration = duration
      @meeting.host_name = current_user.full_name
      @meeting.join_url = response["join_url"]
      @meeting.meeting_number = response["id"]

      if @meeting.save
        invitees.each { |email| @meeting.invitees.create(email: email) }
        redirect_to career_officer_meetings_path, notice: "Meeting '#{@meeting.topic}' successfully scheduled."
      else
        flash.now[:alert] = "Zoom meeting created, but failed to save locally."
        render :new, status: :unprocessable_entity
      end
    rescue Zoom::Error => e
      Rails.logger.error("Zoom meeting creation failed: #{e.message}")
      Rails.logger.error("Zoom API response: #{e.response.body}") if e.respond_to?(:response) && e.response
      flash.now[:alert] = "Failed to schedule meeting."
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @header_text = "Meetings"
    @meetings = Meeting.order(start_time: :desc)
  rescue => e
    Rails.logger.error("Error loading meetings: #{e.message}")
    flash.now[:alert] = "Unable to load meetings."
    @meetings = []
  end

  private

  def set_zoom_access_token
    @access_token = current_user.zoom_credential&.valid_access_token
    if @access_token.blank? && action_name != "index"
      redirect_to career_officer_meetings_path, alert: "Please connect your Zoom account first."
    end
  end

  def meeting_params
    params.require(:meeting).permit(
      :topic, :start_date, :start_hour, :start_minute, :am_pm,
      :duration_hr, :duration_min, :invitees_list
    )
  end
end
