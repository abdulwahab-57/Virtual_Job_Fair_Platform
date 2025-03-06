class Student::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_student, :set_sidebar, :set_path

  private

  def authorize_student
    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "student"
  end

  def set_sidebar
    @sidebar_tabs = []
  end

  def set_path
    @home_path = student_dashboard_path
    @show_profile_path = student_profile_path(current_user.id)
    @edit_profile_path = edit_student_profile_path(current_user.id)
  end
end
