class Student::ProfilesController < Student::BaseController
  before_action :set_user, only: [ :show, :edit, :update ]
  def show
  end

  def edit
  end

  def update
  end

  private
  def set_user
    @user = User.select(:id, :full_name, :email, :profile_picture_url).find(params[:id])
  end
end
