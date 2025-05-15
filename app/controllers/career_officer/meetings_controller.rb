require "ostruct"
class CareerOfficer::MeetingsController < CareerOfficer::BaseController
  before_action :set_zoom_access_token, only: [ :index, :new, :create ]

  def new
    @header_text = "Schedule Meeting"
    @meeting = OpenStruct.new(
      topic: "",
      start_time: Time.current,
      duration: 40,
    )
  end

  def create
    if @access_token.blank?
      redirect_to career_officer_meetings_path, alert: "Zoom is not connected." and return
    end

    # Process the form data to construct a proper start_time
    start_date = params[:meeting][:start_date]
    start_hour = params[:meeting][:start_hour].to_i
    start_minute = params[:meeting][:start_minute].to_i
    am_pm = params[:meeting][:am_pm]

    # Adjust hour for PM
    start_hour += 12 if am_pm == "PM" && start_hour != 12
    start_hour = 0 if am_pm == "AM" && start_hour == 12

    # Create DateTime object
    begin
      start_time = DateTime.parse("#{start_date} #{start_hour}:#{start_minute}:00")
    rescue ArgumentError => e
      flash.now[:alert] = "Invalid date or time format: #{e.message}"
      @meeting = prepare_meeting_from_params
      render :new, status: :unprocessable_entity and return
    end

    # Calculate total duration in minutes
    duration_hr = params[:meeting][:duration_hr].to_i
    duration_min = params[:meeting][:duration_min].to_i
    total_duration = (duration_hr * 60) + duration_min


    # Meeting settings
    meeting_params = {
      topic: params[:meeting][:topic],
      type: 2,
      start_time: start_time.strftime("%Y-%m-%dT%H:%M:%S"),
      duration: total_duration,
      timezone: "UTC",
      settings: {
        participant_video: true,
        mute_upon_entry: true
      }
    }

    # Add invitees if provided
    invitees = []
    if params[:meeting][:invitees].present?
      invitees = params[:meeting][:invitees].split(/[\s,;]+/).map(&:strip).reject(&:empty?)
    end

    # Always add the current user's email to the invitees list
    invitees << current_user.email unless invitees.include?(current_user.email)

    # Set the meeting invitees
    if invitees.any?
      meeting_params[:settings][:meeting_invitees] = invitees.map { |email| { email: email } }
    end

    zoom_client = Zoom::Client::OAuth.new(access_token: @access_token, timeout: 15)
    user = zoom_client.user_get(id: "me")

    begin
      response = zoom_client.meeting_create(user_id: user["id"], **meeting_params)
      redirect_to career_officer_meetings_path, notice: "Meeting '#{meeting_params[:topic]}' successfully scheduled."
    rescue Zoom::Error => e
      Rails.logger.error("Zoom meeting creation failed: #{e.message}")
      Rails.logger.error("Zoom API response: #{e.response.body}") if e.respond_to?(:response) && e.response
      @meeting = prepare_meeting_from_params
      flash.now[:alert] = "Failed to schedule meeting: #{meeting_params}"
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @header_text = "Meetings"

    if @access_token.present?
      zoom_client = Zoom::Client::OAuth.new(access_token: @access_token, timeout: 15)
      user = zoom_client.user_get(id: "me")
      response = zoom_client.meeting_list(user_id: user["id"], type: "scheduled")
      @meetings = response["meetings"]
    else
      @meetings = []
    end
  rescue Zoom::Error => e
    Rails.logger.error("Zoom API error: #{e.message}")
    flash.now[:alert] = "Unable to load Zoom meetings."
    @meetings = []
  end

  private

  def set_zoom_access_token
    @access_token = current_user.zoom_credential&.valid_access_token

    if @access_token.blank? && action_name != "index"
      redirect_to career_officer_meetings_path, alert: "Please connect your Zoom account first."
    end
  end

  def prepare_meeting_from_params
    OpenStruct.new(
      topic: params[:meeting][:topic],
      start_date: params[:meeting][:start_date],
      start_hour: params[:meeting][:start_hour],
      start_minute: params[:meeting][:start_minute],
      am_pm: params[:meeting][:am_pm],
      duration_hr: params[:meeting][:duration_hr],
      duration_min: params[:meeting][:duration_min],
      invitees: params[:meeting][:invitees]
    )
  end
end
