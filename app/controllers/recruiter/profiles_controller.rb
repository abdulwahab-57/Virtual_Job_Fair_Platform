class Recruiter::ProfilesController < Recruiter::BaseController
  before_action :set_user, only: [ :show, :edit, :update ]
  def show
    @header_text= "My Profile"
  end

  def edit
    @header_text= "Edit My Profile"
  end

  def update
    if @user.recruiter_profile.update(recruiter_profile_params)
      redirect_to recruiter_profile_path(@user.id), notice: "Profile updated successfully."
    else
      render :edit, alert: "Failed to update the profile."
    end
  end

  private

  def set_user
    @user = User.select(:id, :full_name, :email, :profile_picture_url).includes(:recruiter_profile).find(params[:id])
  end

  def recruiter_profile_params
    params.require(:recruiter_profile).permit(:company_name, :industry, :about_company, :office_location, :company_email, :company_website, :employee_count)
  end
end
