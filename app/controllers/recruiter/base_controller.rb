class Recruiter::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private
  def set_path
    @home_path = recruiter_path
    @show_profile_path = recruiter_profile_path(4)
    @edit_profile_path = edit_recruiter_profile_path(4)
  end
end
