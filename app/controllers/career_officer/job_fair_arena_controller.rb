class CareerOfficer::JobFairArenaController < CareerOfficer::BaseController
  before_action :set_zoom_access_token, only: [ :index ]
  def index
    @header_text = "Job Fair Arena"

    if @access_token.present?
      begin
        zoom_client = Zoom::Client::OAuth.new(access_token: @access_token, timeout: 15)
        user = zoom_client.user_get(id: "me")
        response = zoom_client.meeting_list(user_id: user["id"], type: "scheduled")

        all_meetings = response["meetings"] || []

        # Filter meetings to only include those where the current user is an invitee
        @meetings = all_meetings.select do |meeting|
          # Get meeting details to access invitees
          begin
            meeting_details = zoom_client.meeting_get(meeting_id: meeting["id"])
            invitees = meeting_details.dig("settings", "meeting_invitees") || []
            invitees.any? { |invitee| invitee["email"] == current_user.email }
          rescue Zoom::Error => e
            Rails.logger.error("Error fetching meeting details: #{e.message}")
            false
          end
        end
        Rails.logger.info("Meetings Response: #{response}")
      rescue Zoom::Error => e
        Rails.logger.error("Zoom API error: #{e.message}")
        flash.now[:alert] = "Unable to load Zoom meetings."
        @meetings = []
      end
    else
      @meetings = []
    end
  end

  def show
    @header_text = "Virtual Booth"


    @meeting_number = params[:id]
    @zoom_sdk_key = Rails.application.credentials.dig(:zoom, :client_id)
    # Generate JWT signature for Zoom Meeting SDK
    # According to Zoom documentation, we must use role=0 for joining meetings
    @zoom_signature = ZoomSdkService.generate_jwt(@meeting_number)
    # Extract password from join_url if present
    @zoom_password = extract_zoom_password(params[:join_url]) if params[:join_url].present?

    # Log information for debugging
    Rails.logger.info("Meeting details for Zoom SDK:")
    Rails.logger.info("  JWT Signature: #{@zoom_signature.present? ? 'Generated' : 'Failed to generate'}")
    Rails.logger.info("  Meeting Password: #{@zoom_password}")
    Rails.logger.info("  Role: 0 (attendee)")
  end

  private

  def set_zoom_access_token
    @access_token = current_user.zoom_credential&.valid_access_token

    if @access_token.blank? && action_name != "index"
      redirect_to career_officer_job_fair_arena_index_path, alert: "Please connect your Zoom account first."
    end
  end

  def extract_zoom_password(join_url)
    uri = URI.parse(join_url)
    query = URI.decode_www_form(uri.query || "")
    query_hash = Hash[query]
    query_hash["pwd"]
  rescue URI::InvalidURIError => e
    Rails.logger.error("Invalid join_url: #{e.message}")
    nil
  end
end
