class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :phone_number, :full_name, :user_type,
      :roll_number, :graduation_year,    # Student fields
      :company_name, :designation,       # Recruiter fields
      :institution_name, :department     # CareerOffice fields
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :phone_number, :full_name, :user_type,
      :roll_number, :graduation_year,
      :company_name, :designation,
      :institution_name, :department
    ])
  end
end
