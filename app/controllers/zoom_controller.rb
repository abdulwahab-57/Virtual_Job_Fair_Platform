class ZoomController < ApplicationController
  before_action :authenticate_user!
  before_action :require_career_officer, only: [ :auth ]

  def auth
    # Generate a random state to prevent CSRF
    state = SecureRandom.hex(10)
    session[:zoom_oauth_state] = state

    Rails.logger.info("Initiating Zoom OAuth flow for user #{current_user.id}")
    Rails.logger.info("Using client ID: #{ENV['ZOOM_CLIENT_ID'][0..5]}...")
    Rails.logger.info("Redirect URI: #{zoom_callback_url}")

    # Redirect to Zoom OAuth authorization URL
    auth_url = "https://zoom.us/oauth/authorize?" + {
      response_type: "code",
      client_id: ENV["ZOOM_CLIENT_ID"],
      redirect_uri: zoom_callback_url,
      state: state
    }.to_query

    Rails.logger.info("Redirecting to Zoom auth URL: #{auth_url[0..50]}...")
    redirect_to auth_url, allow_other_host: true
  end

  def callback
    Rails.logger.info("Received Zoom OAuth callback for user #{current_user.id}")

    # Verify state to prevent CSRF
    if params[:state] != session[:zoom_oauth_state]
      Rails.logger.error("Invalid state parameter in Zoom callback")
      flash[:alert] = "Invalid state parameter. Please try again."
      redirect_to root_path
      return
    end

    Rails.logger.info("State verification successful")

    # Check if we received an error
    if params[:error].present?
      Rails.logger.error("Zoom OAuth error: #{params[:error]} - #{params[:error_description]}")
      flash[:alert] = "Failed to connect to Zoom: #{params[:error_description]}"
      redirect_to root_path
      return
    end

    # Check if we received a code
    if params[:code].blank?
      Rails.logger.error("No authorization code received from Zoom")
      flash[:alert] = "No authorization code received from Zoom. Please try again."
      redirect_to root_path
      return
    end

    Rails.logger.info("Received authorization code: #{params[:code][0..5]}...")

    # Exchange authorization code for access token
    auth_header = "Basic #{Base64.strict_encode64("#{ENV['ZOOM_CLIENT_ID']}:#{ENV['ZOOM_CLIENT_SECRET']}")}"
    Rails.logger.info("Using auth header: #{auth_header[0..15]}...")

    response = HTTParty.post("https://zoom.us/oauth/token", {
      headers: {
        "Authorization" => auth_header,
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        grant_type: "authorization_code",
        code: params[:code],
        redirect_uri: zoom_callback_url
      }
    })

    Rails.logger.info("Token exchange response code: #{response.code}")

    if response.success?
      Rails.logger.info("Successfully received tokens from Zoom")
      Rails.logger.info("Access token: #{response['access_token'][0..5]}...")
      Rails.logger.info("Refresh token: #{response['refresh_token'][0..5]}...")
      Rails.logger.info("Expires in: #{response['expires_in']} seconds")

      # Save the tokens to the database
      current_user.zoom_credential&.destroy

      credential = current_user.create_zoom_credential(
        access_token: response["access_token"],
        refresh_token: response["refresh_token"],
        expires_at: Time.current + response["expires_in"].to_i.seconds
      )

      if credential.persisted?
        Rails.logger.info("Successfully saved Zoom credentials to database")
      else
        Rails.logger.error("Failed to save Zoom credentials: #{credential.errors.full_messages.join(', ')}")
      end

      flash[:notice] = "Successfully connected to Zoom!"
      redirect_to career_officer_dashboard_path
    else
      error_description = response["error_description"] || response.body
      Rails.logger.error("Failed to exchange code for token: #{error_description}")
      flash[:alert] = "Failed to connect to Zoom: #{error_description}"
      redirect_to root_path
    end
  end

  private

  def require_career_officer
    unless current_user.career_officer?
      flash[:alert] = "Only career officers can connect to Zoom."
      redirect_to root_path
    end
  end
end
