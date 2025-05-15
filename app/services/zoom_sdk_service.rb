require "jwt"

class ZoomSdkService
  class << self
    # Generate JWT for Zoom Meeting SDK
    # This method follows the same logic as the API endpoint provided
    def generate_jwt(meeting_number, role = 0, expiration_seconds = 7200)
      Rails.logger.info("Generating JWT for Zoom Meeting SDK")
      Rails.logger.info("  SDK Key: #{Rails.application.credentials.dig(:zoom, :client_id)}")
      Rails.logger.info("  Meeting Number: #{meeting_number}")
      Rails.logger.info("  Role: #{role}")

      # Get the SDK key and secret from environment variables
      sdk_key = Rails.application.credentials.dig(:zoom, :client_id)
      sdk_secret = Rails.application.credentials.dig(:zoom, :client_secret)

      if sdk_key.blank? || sdk_secret.blank?
        Rails.logger.error("Missing Zoom SDK credentials")
        return nil
      end

      # Create the JWT payload
      iat = Time.now.to_i
      exp = iat + expiration_seconds

      header={
        "alg" => "HS256",
        "typ" => "JWT"
      }

      payload = {
        appKey: sdk_key,
        sdkKey: sdk_key,
        mn: meeting_number,
        role: role,
        iat: iat,
        exp: exp,
        tokenExp: exp
      }


      Rails.logger.info("  Issued at: #{iat}")
      Rails.logger.info("  Expires at: #{exp}")

      # Generate the JWT
      begin
        token = JWT.encode(payload, sdk_secret, "HS256", header)
        Rails.logger.info("  JWT generated successfully")
        token
      rescue => e
        Rails.logger.error("Failed to generate JWT: #{e.message}")
        nil
      end
    end
  end
end
