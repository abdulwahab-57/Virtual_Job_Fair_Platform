module ZoomIntegration
  extend ActiveSupport::Concern

  included do
    # Check if user has Zoom credentials
    def has_zoom_credentials?
      zoom_credential.present?
    end

    # Get valid Zoom access token
    def zoom_access_token
      return nil unless has_zoom_credentials?

      Rails.logger.info("User #{id} requesting Zoom access token")
      token = zoom_credential.valid_access_token

      if token.blank?
        Rails.logger.error("Failed to get valid access token for user #{id}")
        return nil
      end

      token
    end
  end
end
