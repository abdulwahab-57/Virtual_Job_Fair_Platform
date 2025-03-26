class CareerOfficer::JobFairArenaController < CareerOfficer::BaseController
  before_action :set_meeting, only: [ :show ]

  def index
    @header_text = "Job Fair Arena"
    # Combine active and upcoming meetings for the grid view
    @meetings = Meeting.where(status: [ "started", "scheduled" ])
                       .where("end_time > ?", Time.current.utc)
                       .order(start_time: :asc)
  end

  def show
    unless @meeting.active? || current_user.id == @meeting.host_id
      redirect_to career_officer_job_fair_arena_index_path, alert: "This meeting is not currently active."
      return
    end

    # Make sure the career officer is a participant
    unless @meeting.participant?(current_user)
      @meeting.add_participant(current_user, "co-host")
    end

    # Extract meeting number from the Zoom URL
    @meeting_number = extract_meeting_number(@meeting.zoom_meeting_url)

    if @meeting_number.present?
      # Check if we have a password
      if @meeting.zoom_meeting_password.blank?
        Rails.logger.warn("Meeting password is missing, using fallback password")
        # Use a fallback password - this is a common issue with Zoom meetings
        # Often the password is embedded in the URL or is a default like "password"
        @meeting_password = extract_password_from_url(@meeting.zoom_meeting_url) || "password"
      else
        @meeting_password = @meeting.zoom_meeting_password
      end

      # Generate JWT signature for Zoom Meeting SDK
      # According to Zoom documentation, we must use role=0 for joining meetings
      @zoom_signature = ZoomSdkService.generate_jwt(@meeting_number)

      # Log information for debugging
      Rails.logger.info("Meeting details for Zoom SDK:")
      Rails.logger.info("  Meeting Number: #{@meeting_number}")
      Rails.logger.info("  Meeting Password: #{@meeting_password.present? ? @meeting_password : 'Missing'}")
      Rails.logger.info("  JWT Signature: #{@zoom_signature.present? ? 'Generated' : 'Failed to generate'}")
      Rails.logger.info("  Role: 0 (attendee)")
    else
      Rails.logger.error("Failed to extract meeting number from URL: #{@meeting.zoom_meeting_url}")
    end
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:id])
  end

  def extract_meeting_number(zoom_url)
    return nil if zoom_url.blank?

    # Extract meeting number from Zoom URL (e.g., https://zoom.us/j/1234567890)
    match = zoom_url.match(/\/j\/(\d+)/)

    if match
      meeting_number = match[1]
      Rails.logger.info("Successfully extracted meeting number: #{meeting_number}")
      meeting_number
    else
      Rails.logger.error("Could not extract meeting number from URL: #{zoom_url}")
      nil
    end
  end

  def extract_password_from_url(zoom_url)
    return nil if zoom_url.blank?

    # Try to extract password from URL (e.g., https://zoom.us/j/1234567890?pwd=abcdef)
    match = zoom_url.match(/pwd=([^&]+)/)

    if match
      password = match[1]
      Rails.logger.info("Successfully extracted password from URL: #{password}")
      password
    else
      Rails.logger.warn("Could not extract password from URL: #{zoom_url}")
      nil
    end
  end
end
