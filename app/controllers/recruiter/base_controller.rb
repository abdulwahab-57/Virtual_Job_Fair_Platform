class Recruiter::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_recruiter, :set_sidebar, :set_path

  private

  def authorize_recruiter
    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "recruiter"
  end

  def set_sidebar
    begin
      # Try using the route helpers, but fallback to hardcoded paths if they fail
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: recruiter_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Job Fair Arena", icon: "video", path: recruiter_job_fair_arena_index_path },
        { label: "GitHub Student Rankings", icon: "chart-bar", path: recruiter_github_analyzer_rankings_path },
        { label: "GitHub Skills Analysis", icon: "chart-bar", path: recruiter_github_analyzer_skills_path },
        { label: "GitHub Activity Timeline", icon: "chart-bar", path: recruiter_github_analyzer_activity_path },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
    rescue => e
      # If any route helpers fail, use hardcoded paths as fallback
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: "/recruiter/dashboard" },
        { label: "Inbox", icon: "chat", path: "/inbox" },
        { label: "Job Fair Arena", icon: "video", path: "/recruiter/job_fair_arena" },
        { label: "GitHub Student Rankings", icon: "chart-bar", path: "/recruiter/github_analyzer/rankings" },
        { label: "GitHub Skills Analysis", icon: "chart-bar", path: "/recruiter/github_analyzer/skills" },
        { label: "GitHub Activity Timeline", icon: "chart-bar", path: "/recruiter/github_analyzer/activity" },
        { label: "Analytics", icon: "chart-bar", path: "/analytics" }
      ]
    end
    @home_path = "/recruiter/dashboard" # Use a simple string path as fallback
  end

  def set_path
    @home_path = recruiter_dashboard_path
    @show_profile_path = recruiter_profile_path(current_user.id)
    @edit_profile_path = edit_recruiter_profile_path(current_user.id)
  end
end
