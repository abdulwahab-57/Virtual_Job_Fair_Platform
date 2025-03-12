class ZoomService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Create a new Zoom meeting
  def create_meeting(meeting)
    Rails.logger.info("Creating Zoom meeting for meeting ID: #{meeting.id}")
    Rails.logger.info("Original meeting start_time: #{meeting.start_time}")
    Rails.logger.info("Original meeting end_time: #{meeting.end_time}")
    return { success: false, error: "No Zoom credentials found" } unless user.has_zoom_credentials?

    make_request do
      Rails.logger.info("Making Zoom API request to create meeting")
      token = user.zoom_credential.valid_access_token

      if token.blank?
        Rails.logger.error("Failed to get valid Zoom access token")
        return { success: false, error: "Failed to get valid Zoom access token" }
      end

      # Use UTC time for Zoom API - the meeting time is already in UTC in the database
      # (converted from PKT by subtracting 5 hours in the controller)
      meeting_time_utc = meeting.start_time.utc
      Rails.logger.info("Meeting time (UTC): #{meeting_time_utc}")

      # For display, show the PKT time (UTC+5)
      pkt_time = meeting_time_utc + 5.hours
      Rails.logger.info("Meeting time (PKT): #{pkt_time}")

      # Format time for Zoom API (ISO8601 format with Z suffix for UTC)
      formatted_time = meeting_time_utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      Rails.logger.info("Formatted time for Zoom API: #{formatted_time}")

      # Add the time to the meeting title for clarity (show both UTC and PKT)
      meeting_title = "#{meeting.title} (#{meeting_time_utc.strftime("%I:%M %p")} UTC / #{pkt_time.strftime("%I:%M %p")} PKT)"
      Rails.logger.info("Meeting title with time: #{meeting_title}")

      response = HTTParty.post(
        "https://api.zoom.us/v2/users/me/meetings",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        },
        body: {
          topic: meeting_title,
          type: 2,
          start_time: formatted_time,
          duration: ((meeting.end_time - meeting.start_time) / 60).to_i,
          timezone: "UTC",
          settings: {
            host_video: true,
            participant_video: true,
            join_before_host: true,
            mute_upon_entry: false,
            watermark: false,
            use_pmi: false,
            approval_type: 0,
            audio: "both",
            auto_recording: "none"
          }
        }.to_json
      )

      Rails.logger.info("Zoom API response code: #{response.code}")
      Rails.logger.info("Zoom API response body: #{response.body}")

      if response.success?
        Rails.logger.info("Successfully created Zoom meeting with ID: #{response['id']}")
        meeting.update(
          zoom_meeting_id: response["id"],
          zoom_meeting_url: response["join_url"],
          zoom_meeting_password: response["password"],
          status: "scheduled"
        )
        { success: true, meeting: meeting }
      else
        error_message = response["message"] || response.body
        Rails.logger.error("Failed to create Zoom meeting: #{error_message}")

        # Check if token is invalid and force refresh
        if response.code == 401 || (response["message"] && response["message"].include?("Invalid access token"))
          Rails.logger.info("Detected invalid token, forcing refresh")
          user.zoom_credential.refresh_if_expired
        end

        { success: false, error: "Failed to create Zoom meeting: #{error_message}" }
      end
    end
  end

  # Update an existing Zoom meeting
  def update_meeting(meeting)
    Rails.logger.info("Updating Zoom meeting for meeting ID: #{meeting.id}")
    Rails.logger.info("Original meeting start_time: #{meeting.start_time}")
    Rails.logger.info("Original meeting end_time: #{meeting.end_time}")
    return { success: false, error: "No Zoom credentials found" } unless user.has_zoom_credentials?
    return { success: false, error: "No Zoom meeting ID found" } unless meeting.zoom_meeting_id.present?

    make_request do
      Rails.logger.info("Making Zoom API request to update meeting")
      token = user.zoom_credential.valid_access_token

      if token.blank?
        Rails.logger.error("Failed to get valid Zoom access token")
        return { success: false, error: "Failed to get valid Zoom access token" }
      end

      # Use UTC time for Zoom API - the meeting time is already in UTC in the database
      # (converted from PKT by subtracting 5 hours in the controller)
      meeting_time_utc = meeting.start_time.utc
      Rails.logger.info("Meeting time (UTC): #{meeting_time_utc}")

      # For display, show the PKT time (UTC+5)
      pkt_time = meeting_time_utc + 5.hours
      Rails.logger.info("Meeting time (PKT): #{pkt_time}")

      # Format time for Zoom API (ISO8601 format with Z suffix for UTC)
      formatted_time = meeting_time_utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      Rails.logger.info("Formatted time for Zoom API: #{formatted_time}")

      # Add the time to the meeting title for clarity (show both UTC and PKT)
      meeting_title = "#{meeting.title} (#{meeting_time_utc.strftime("%I:%M %p")} UTC / #{pkt_time.strftime("%I:%M %p")} PKT)"
      Rails.logger.info("Meeting title with time: #{meeting_title}")

      response = HTTParty.patch(
        "https://api.zoom.us/v2/meetings/#{meeting.zoom_meeting_id}",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        },
        body: {
          topic: meeting_title,
          type: 2,
          start_time: formatted_time,
          duration: ((meeting.end_time - meeting.start_time) / 60).to_i,
          timezone: "UTC",
          settings: {
            host_video: true,
            participant_video: true,
            join_before_host: true,
            mute_upon_entry: false,
            watermark: false,
            use_pmi: false,
            approval_type: 0,
            audio: "both",
            auto_recording: "none"
          }
        }.to_json
      )

      Rails.logger.info("Zoom API response code: #{response.code}")
      Rails.logger.info("Zoom API response body: #{response.body}")

      if response.success?
        Rails.logger.info("Successfully updated Zoom meeting")
        { success: true, meeting: meeting }
      else
        error_message = response["message"] || response.body
        Rails.logger.error("Failed to update Zoom meeting: #{error_message}")

        # Check if token is invalid and force refresh
        if response.code == 401 || (response["message"] && response["message"].include?("Invalid access token"))
          Rails.logger.info("Detected invalid token, forcing refresh")
          user.zoom_credential.refresh_if_expired
        end

        { success: false, error: "Failed to update Zoom meeting: #{error_message}" }
      end
    end
  end

  # Delete a Zoom meeting
  def delete_meeting(meeting)
    Rails.logger.info("Deleting Zoom meeting for meeting ID: #{meeting.id}")
    return { success: false, error: "No Zoom credentials found" } unless user.has_zoom_credentials?
    return { success: false, error: "No Zoom meeting ID found" } unless meeting.zoom_meeting_id.present?

    make_request do
      Rails.logger.info("Making Zoom API request to delete meeting")
      token = user.zoom_credential.valid_access_token

      if token.blank?
        Rails.logger.error("Failed to get valid Zoom access token")
        return { success: false, error: "Failed to get valid Zoom access token" }
      end

      Rails.logger.info("Using access token: #{token[0..5]}...")

      response = HTTParty.delete(
        "https://api.zoom.us/v2/meetings/#{meeting.zoom_meeting_id}",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        }
      )

      Rails.logger.info("Zoom API response code: #{response.code}")
      Rails.logger.info("Zoom API response body: #{response.body}")

      if response.success? || response.code == 204
        Rails.logger.info("Successfully deleted Zoom meeting")
        meeting.update(status: "cancelled")
        { success: true }
      else
        error_message = response["message"] || response.body
        Rails.logger.error("Failed to delete Zoom meeting: #{error_message}")

        # Check if token is invalid and force refresh
        if response.code == 401 || (response["message"] && response["message"].include?("Invalid access token"))
          Rails.logger.info("Detected invalid token, forcing refresh")
          user.zoom_credential.refresh_if_expired
        end

        { success: false, error: "Failed to delete Zoom meeting: #{error_message}" }
      end
    end
  end

  # Get meeting status
  def get_meeting_status(meeting)
    Rails.logger.info("Getting status for Zoom meeting ID: #{meeting.id}")
    return { success: false, error: "No Zoom credentials found" } unless user.has_zoom_credentials?
    return { success: false, error: "No Zoom meeting ID found" } unless meeting.zoom_meeting_id.present?

    make_request do
      Rails.logger.info("Making Zoom API request to get meeting status")
      token = user.zoom_credential.valid_access_token

      if token.blank?
        Rails.logger.error("Failed to get valid Zoom access token")
        return { success: false, error: "Failed to get valid Zoom access token" }
      end

      Rails.logger.info("Using access token: #{token[0..5]}...")

      response = HTTParty.get(
        "https://api.zoom.us/v2/meetings/#{meeting.zoom_meeting_id}",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        }
      )

      Rails.logger.info("Zoom API response code: #{response.code}")
      Rails.logger.info("Zoom API response body: #{response.body}")

      if response.success?
        Rails.logger.info("Successfully got Zoom meeting status: #{response['status']}")
        { success: true, status: response["status"] }
      else
        error_message = response["message"] || response.body
        Rails.logger.error("Failed to get Zoom meeting status: #{error_message}")

        # Check if token is invalid and force refresh
        if response.code == 401 || (response["message"] && response["message"].include?("Invalid access token"))
          Rails.logger.info("Detected invalid token, forcing refresh")
          user.zoom_credential.refresh_if_expired
        end

        { success: false, error: "Failed to get Zoom meeting status: #{error_message}" }
      end
    end
  end

  private

  def make_request
    retries = 0
    begin
      Rails.logger.info("Making Zoom API request (attempt #{retries + 1})")
      result = yield
      Rails.logger.info("Zoom API request completed with result: #{result[:success]}")
      result
    rescue => e
      Rails.logger.error("Zoom API request failed with error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      if retries < 1
        retries += 1
        Rails.logger.info("Refreshing token and retrying (attempt #{retries + 1})")
        user.zoom_credential.refresh_if_expired
        retry
      else
        Rails.logger.error("Max retries reached, giving up")
        { success: false, error: "Failed to make Zoom API request: #{e.message}" }
      end
    end
  end
end
