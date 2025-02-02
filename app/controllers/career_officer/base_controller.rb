class CareerOfficer::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private
  def set_path
    @home_path = career_officer_path
    @show_profile_path = career_officer_profile_path(7)
    @edit_profile_path = edit_career_officer_profile_path(7)
  end
end
