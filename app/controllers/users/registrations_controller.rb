class RegistrationsController < Devise::RegistrationsController
  def new
    build_resource
    # Initialize nested attributes for different user types
    resource.build_profile
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    # Assign profile based on user_type
    if params[:user][:profile]
      case resource.user_type
      when "student"
        resource.profile = Student.new(student_params)
      when "recruiter"
        resource.profile = Recruiter.new(recruiter_params)
      when "career_office"
        resource.profile = CareerOffice.new(career_office_params)
      end
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

  private

  def sign_up_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :full_name,
      :user_type
    )
  end

  def student_params
    params.require(:user).require(:profile).permit(:email_personal)
  rescue ActionController::ParameterMissing
    {}
  end

  def recruiter_params
    params.require(:user).require(:profile).permit(:company_name)
  rescue ActionController::ParameterMissing
    {}
  end

  def career_office_params
    params.require(:user).require(:profile).permit(:designation)
  rescue ActionController::ParameterMissing
    {}
  end
end
