class Student::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_access, :set_sidebar_path, :set_path

  private

  def authorize_access
    allowed_for_career_officer = %w[show edit]

    return true if current_user.user_type == "career_officer" && allowed_for_career_officer.include?(action_name)

    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "student"
  end

  def set_sidebar_path
    @sidebar = "shared/student_sidebar"
  end

  def set_path
    @home_path = student_dashboard_path
    @show_profile_path = student_profile_path(current_user.id)
    @edit_profile_path = edit_student_profile_path(current_user.id)
  end
end
