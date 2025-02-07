class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :full_name,
      :user_type,
      student_profile_attributes: [ :email_personal ],
      recruiter_profile_attributes: [ :company_name ],
      career_officer_profile_attributes: [ :designation ]
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :full_name,
      :email,
      student_profile_attributes: [ :email_personal ],
      recruiter_profile_attributes: [ :company_name ],
      career_officer_profile_attributes: [ :designation ]
    ])
  end
end
