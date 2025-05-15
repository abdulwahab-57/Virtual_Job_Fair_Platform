class Student::JobFairArenaController < Student::BaseController
  def index
    @header_text = "Job Fair Arena"
    user_email = current_user.email

    begin
      @meetings = Meeting
        .joins(:invitees)
        .where(invitees: { email: user_email })
        .order(start_time: :asc)
    rescue => e
      Rails.logger.error("Error loading invited meetings: #{e.message}")
      flash.now[:alert] = "Unable to load meetings."
      @meetings = []
    end

    render template: "career_officer/job_fair_arena/index"
  end

  def show
    @header_text = "Virtual Booth"


    @meeting_number = params[:id]
    @zoom_sdk_key = Rails.application.credentials.dig(:zoom, :client_id)
    # Generate JWT signature for Zoom Meeting SDK
    # According to Zoom documentation, we must use role=0 for joining meetings
    @zoom_signature = ZoomSdkService.generate_jwt(@meeting_number)
    # Extract password from join_url if present
    @zoom_password = extract_zoom_password(params[:join_url]) if params[:jomin_url].present?

    # Log information for debugging
    Rails.logger.info("Meeting details for Zoom SDK:")
    Rails.logger.info("  JWT Signature: #{@zoom_signature.present? ? 'Generated' : 'Failed to generate'}")
    Rails.logger.info("  Meeting Password: #{@zoom_password}")
    Rails.logger.info("  Role: 0 (attendee)")

    render template: "career_officer/job_fair_arena/show"
  end

  private

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
