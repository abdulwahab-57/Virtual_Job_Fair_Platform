class ZoomCredential < ApplicationRecord
  belongs_to :user

  # Encrypt sensitive data using attr_encrypted
  attr_encrypted :access_token, key: ENV["ENCRYPTION_KEY"]
  attr_encrypted :refresh_token, key: ENV["ENCRYPTION_KEY"]

  # Check if the token is expired
  def expired?
    is_expired = expires_at.present? && expires_at < Time.current
    Rails.logger.info("Zoom token expired check: #{is_expired} (expires_at: #{expires_at}, current: #{Time.current})")
    is_expired
  end

  # Refresh the token if it's expired
  def refresh_if_expired
    Rails.logger.info("Checking if Zoom token needs refresh...")

    unless expired?
      Rails.logger.info("Zoom token is still valid, no refresh needed")
      return true
    end

    Rails.logger.info("Zoom token is expired, attempting to refresh...")

    # Log the refresh token (first few characters only for security)
    safe_refresh_token = refresh_token.present? ? "#{refresh_token[0..5]}..." : "nil"
    Rails.logger.info("Using refresh token: #{safe_refresh_token}")

    # Log the client credentials (first few characters only for security)
    client_id = ENV["ZOOM_CLIENT_ID"]
    client_secret = ENV["ZOOM_CLIENT_SECRET"]
    safe_client_id = client_id.present? ? "#{client_id[0..5]}..." : "nil"
    safe_client_secret = client_secret.present? ? "#{client_secret[0..5]}..." : "nil"
    Rails.logger.info("Using client ID: #{safe_client_id}, client secret: #{safe_client_secret}")

    auth_header = "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}"
    safe_auth_header = "Basic #{auth_header[6..15]}..."
    Rails.logger.info("Authorization header: #{safe_auth_header}")

    response = HTTParty.post("https://zoom.us/oauth/token", {
      headers: {
        "Authorization" => auth_header,
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        grant_type: "refresh_token",
        refresh_token: refresh_token
      }
    })

    Rails.logger.info("Zoom token refresh response code: #{response.code}")
    Rails.logger.info("Zoom token refresh response body: #{response.body}")

    if response.success?
      Rails.logger.info("Successfully refreshed Zoom token")
      update(
        access_token: response["access_token"],
        refresh_token: response["refresh_token"],
        expires_at: Time.current + response["expires_in"].to_i.seconds
      )
      true
    else
      Rails.logger.error("Failed to refresh Zoom token: #{response.body}")
      false
    end
  rescue => e
    Rails.logger.error("Error refreshing Zoom token: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    false
  end

  # Get a valid access token
  def valid_access_token
    Rails.logger.info("Getting valid Zoom access token...")
    refresh_result = refresh_if_expired
    Rails.logger.info("Token refresh result: #{refresh_result}")

    # Log the access token (first few characters only for security)
    safe_access_token = access_token.present? ? "#{access_token[0..5]}..." : "nil"
    Rails.logger.info("Using access token: #{safe_access_token}")

    access_token
  end
end
