class CareerOfficer::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private
  def set_path
    @home_path = career_officer_path
    @profile_path = career_officer_profile_path(18)
  end
end
