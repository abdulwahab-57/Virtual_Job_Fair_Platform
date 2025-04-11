class Recruiter::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_recruiter, :set_sidebar, :set_path

  private

  def authorize_recruiter
    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "recruiter"
  end

  def set_sidebar
    @sidebar_tabs = [ { label: "Virtual Booth", icon: "video", path: "#" } ]
  end

  def set_path
    @home_path = recruiter_dashboard_path
    @show_profile_path = recruiter_profile_path(current_user.id)
    @edit_profile_path = edit_recruiter_profile_path(current_user.id)
  end
end
