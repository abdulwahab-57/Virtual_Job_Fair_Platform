class CareerOfficer::ProfilesController < CareerOfficer::BaseController
  before_action :set_user, only: [ :show, :edit, :update ]
  def show
    @header_text= "My Profile"
  end

  def edit
    @header_text= "Edit My Profile"
  end

  def update
    ActiveRecord::Base.transaction do
      @user.update!(user_params)
      @user.career_officer_profile.update!(career_officer_profile_params)
    end
    redirect_to career_officer_profile_path(@user.id), notice: "Profile updated successfully."
  rescue ActiveRecord::RecordInvalid => e
    render :edit, alert: "Failed to update the profile: #{e.message}"
  end

  private

  def set_user
     @user = User.select(:id, :full_name, :email, :profile_picture_url).includes(:career_officer_profile).find(params[:id])
  end

  def career_officer_profile_params
    params.require(:user).permit(career_officer_profile_attributes: [ :designation, :introduction, :education, :office_location, :phone_number ])[:career_officer_profile_attributes]
  end

  def user_params
    params.require(:user).permit(:full_name, :email)
  end
end
