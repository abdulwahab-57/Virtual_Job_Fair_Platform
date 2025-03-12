require "jwt"

class ZoomSdkService
  class << self
    # Generate JWT for Zoom Meeting SDK
    # This method follows the same logic as the API endpoint provided
    def generate_jwt(meeting_number, role, expiration_seconds = 7200)
      Rails.logger.info("Generating JWT for Zoom Meeting SDK")
      Rails.logger.info("  SDK Key: #{ENV['ZOOM_CLIENT_ID']}")
      Rails.logger.info("  Meeting Number: #{meeting_number}")
      Rails.logger.info("  Role: #{role}")

      # Get the SDK key and secret from environment variables
      sdk_key = ENV["ZOOM_CLIENT_ID"]
      sdk_secret = ENV["ZOOM_CLIENT_SECRET"]

      if sdk_key.blank? || sdk_secret.blank?
        Rails.logger.error("Missing Zoom SDK credentials")
        return nil
      end

      # Create the JWT payload
      iat = Time.now.to_i
      exp = iat + expiration_seconds

      payload = {
        appKey: sdk_key,
        sdkKey: sdk_key,
        mn: meeting_number,
        role: role,
        iat: iat,
        exp: exp,
        tokenExp: exp
      }

      Rails.logger.info("  Issued at: #{Time.at(iat)}")
      Rails.logger.info("  Expires at: #{Time.at(exp)}")

      # Generate the JWT
      begin
        token = JWT.encode(payload, sdk_secret, "HS256")
        Rails.logger.info("  JWT generated successfully")
        token
      rescue => e
        Rails.logger.error("Failed to generate JWT: #{e.message}")
        nil
      end
    end

    # Legacy method for backward compatibility
    def generate_signature(meeting_number, role = 0)
      generate_jwt(meeting_number, role)
    end

    # Generate a web signature for Zoom Meeting SDK
    # This is an alternative method that can be used if needed
    def generate_web_signature(meeting_number, role = 0)
      Rails.logger.info("Generating web signature for Zoom Meeting SDK")
      Rails.logger.info("  SDK Key: #{ENV['ZOOM_CLIENT_ID']}")
      Rails.logger.info("  Meeting Number: #{meeting_number}")
      Rails.logger.info("  Role: #{role}")

      # Get the SDK key and secret from environment variables
      sdk_key = ENV["ZOOM_CLIENT_ID"]
      sdk_secret = ENV["ZOOM_CLIENT_SECRET"]

      if sdk_key.blank? || sdk_secret.blank?
        Rails.logger.error("Missing Zoom SDK credentials")
        return nil
      end

      # Create the signature string
      timestamp = Time.now.to_i * 1000 - 30000
      msg = "#{sdk_key}#{meeting_number}#{timestamp}#{role}"

      # Generate the signature
      begin
        hash = OpenSSL::HMAC.digest("sha256", sdk_secret, msg)
        signature = Base64.strict_encode64(hash)
        signature_string = "#{sdk_key}.#{meeting_number}.#{timestamp}.#{role}.#{signature}"

        Rails.logger.info("  Web signature generated successfully")
        signature_string
      rescue => e
        Rails.logger.error("Failed to generate web signature: #{e.message}")
        nil
      end
    end
  end
end
