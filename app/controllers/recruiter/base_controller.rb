class Recruiter::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private
  def set_path
    @home_path = recruiter_path
    @profile_path = recruiter_profile_path(15)
  end
end
