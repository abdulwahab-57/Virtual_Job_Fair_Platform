class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]

  def new
    super
    build_profile_for_user_type
  end

  def create
    build_resource(sign_up_params)
    initialize_profile
    save_user_and_handle_response
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(
        :email,
        :password,
        :password_confirmation,
        :full_name,
        :user_type,
        student_profile_attributes: [ :email_personal ],
        recruiter_profile_attributes: [ :company_name ],
        career_officer_profile_attributes: [ :designation ]
      )
    end
  end

  def after_sign_up_path_for(resource)
    case resource.user_type
    when "student"
      student_dashboard_path
    when "recruiter"
      recruiter_dashboard_path
    when "career_officer"
      career_officer_dashboard_path
    else
      root_path
    end
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def save_user_and_handle_response
    resource.save
    yield resource if block_given?

    if resource.persisted?
      handle_successful_signup(resource)
    else
      handle_failed_signup(resource)
    end
  end

  def handle_successful_signup(resource)
    if resource.active_for_authentication?
      set_flash_message! :notice, :signed_up
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
      expire_data_after_sign_in!
      respond_with resource, location: after_inactive_sign_up_path_for(resource)
    end
  end

  def handle_failed_signup(resource)
    Rails.logger.error "Validation errors: #{resource.errors.full_messages.join(', ')}"
    clean_up_passwords resource
    set_minimum_password_length
    respond_with resource
  end

  def initialize_profile
    profile_attributes = sign_up_params.dig("#{resource.user_type}_profile_attributes".to_sym) || {}
    resource.send("build_#{resource.user_type}_profile", profile_attributes)
  end

  def build_profile_for_user_type
    return unless resource.user_type
    resource.send("build_#{resource.user_type}_profile") unless resource.send("#{resource.user_type}_profile")
  end
end
