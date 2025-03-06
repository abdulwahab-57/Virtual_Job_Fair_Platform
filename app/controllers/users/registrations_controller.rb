class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]

  def new
    super
    build_profile_for_user_type
  end

  def create
    build_resource(sign_up_params)

    # Initialize the appropriate profile based on user type
    initialize_profile

    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      # Log validation errors for debugging
      Rails.logger.error "Validation errors: #{resource.errors.full_messages.join(', ')}"
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
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
        student_profile_attributes: [ :email_personal ], # Ensure this is correct
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
 # Add this method to handle redirection after inactive sign-up (email confirmation)
 def after_inactive_sign_up_path_for(resource)
  new_user_session_path # Redirect to login page after signup
 end


  private

  def initialize_profile
    case resource.user_type
    when "student"
      resource.build_student_profile(sign_up_params.dig(:student_profile_attributes) || {})
    when "recruiter"
      resource.build_recruiter_profile(sign_up_params.dig(:recruiter_profile_attributes) || {})
    when "career_officer"
      resource.build_career_officer_profile(sign_up_params.dig(:career_officer_profile_attributes) || {})
    end
  end

  def build_profile_for_user_type
    return unless resource.user_type

    case resource.user_type
    when "student"
      resource.build_student_profile unless resource.student_profile
    when "recruiter"
      resource.build_recruiter_profile unless resource.recruiter_profile
    when "career_officer"
      resource.build_career_officer_profile unless resource.career_officer_profile
    end
  end
end
