class Users::RegistrationsController < Devise::RegistrationsController
  def new
    build_resource
    resource.build_student_profile
    resource.build_recruiter_profile
    resource.build_career_officer_profile
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    case resource.user_type
    when "student"
      resource.student_profile_attributes = StudentProfile.new(student_params)
    when "recruiter"
      resource.recruiter_profile_attributes = RecruiterProfile.new(recruiter_params)
    when "career_office"
      resource.career_officer_profile_attributes = CareerOfficerProfile.new(career_office_params)
    end


    if resource.save
      # Custom logic after successful signup
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_sign_up_path_for(resource)
    case resource.user_type
    when "student"
      student_path
    when "recruiter"
      recruiter_path
    when "career_office"
      career_officer_path
    else
      root_path # Fallback for unexpected user types
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :user_type,
      :full_name,
      :email,
      :password,
    )
  end

  def student_params
    params.require(:user).require(:student_profile_attributes).permit(:email_personal)
  rescue ActionController::ParameterMissing
    {}
  end

  def recruiter_params
    params.require(:user).require(:recruiter_profile_attributes).permit(:company_name)
  rescue ActionController::ParameterMissing
    {}
  end

  def career_office_params
    params.require(:user).require(:career_officer_profile_attributes).permit(:designation)
  rescue ActionController::ParameterMissing
    {}
  end
end
