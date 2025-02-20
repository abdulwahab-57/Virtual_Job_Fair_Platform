class Student::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_student, :set_path

  private

  def authorize_student
    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "student"
  end

  def set_path
    @home_path = student_dashboard_path # Use the correct route helper for the dashboard
    @show_profile_path = student_profile_path(current_user.id) # No need to pass an ID for singular resource
    @edit_profile_path = edit_student_profile_path(current_user.id) # No need to pass an ID for singular resource
  end
end
