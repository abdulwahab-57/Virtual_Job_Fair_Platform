class CareerOfficer::BaseController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :authorize_career_officer, :set_sidebar_path, :set_path

  private

  def authorize_career_officer
    redirect_to new_user_session_path, alert: "Access denied!" unless current_user.user_type == "career_officer"
  end

  def set_sidebar_path
    @sidebar = "shared/career_officer_sidebar"
  end

  def set_path
    @home_path = career_officer_dashboard_path
    @show_profile_path = career_officer_profile_path(current_user.id)
    @edit_profile_path = edit_career_officer_profile_path(current_user.id)
  end
end
