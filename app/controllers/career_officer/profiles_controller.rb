class CareerOfficer::ProfilesController < CareerOfficer::BaseController
  def show
    @user = User.select(:id, :first_name, :last_name, :email, :profile_picture_url).find(params[:id])
  end
  def edit
  end
end
