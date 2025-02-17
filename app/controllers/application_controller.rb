class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :full_name,
      :user_type,
      student_profile_attributes: [ :email_personal, :date_of_birth, :phone_number, :address, :linkedin_url ],
      recruiter_profile_attributes: [ :company_name, :industry, :about_company, :office_location, :company_email, :company_website ],
      career_officer_profile_attributes: [ :designation, :introduction, :education, :office_location, :phone_number ]
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :full_name,
      :email,
      student_profile_attributes: [ :email_personal, :date_of_birth, :phone_number, :address, :linkedin_url ],
      recruiter_profile_attributes: [ :company_name, :industry, :about_company, :office_location, :company_email, :company_website ],
      career_officer_profile_attributes: [ :designation, :introduction, :education, :office_location, :phone_number ]
    ])
  end
end
