class CareerOfficer::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_career_officer, :set_sidebar, :set_path

  private

  def authorize_career_officer
    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "career_officer"
  end

  def set_sidebar
    @sidebar_tabs = [
      { label: "Home", icon: "home", path: career_officer_dashboard_path },
      { label: "Student Profiles", icon: "users", path: career_officer_student_profiles_path },
<<<<<<< HEAD
      { label: "Job Fair Arena", icon: "video", path: career_officer_job_fair_arena_index_path },
      { label: "Meetings", icon: "calendar", path: career_officer_meetings_path }
=======
      { label: "Job Fair Arena", icon: "video", path: "#" },
      { label: "Meetings", icon: "calendar", path: "#" },
      { label: "Analytics", icon: "chart-bar", path: analytics_path }
>>>>>>> analytics-report-management
    ]
  end

  def set_path
    @home_path = career_officer_dashboard_path
    @show_profile_path = career_officer_profile_path(current_user.id)
    @edit_profile_path = edit_career_officer_profile_path(current_user.id)
  end
end
