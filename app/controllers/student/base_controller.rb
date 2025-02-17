class Student::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private

  def set_path
    @home_path = student_dashboard_path # Use the correct route helper for the dashboard
    @show_profile_path = student_profile_path # No need to pass an ID for singular resource
    @edit_profile_path = edit_student_profile_path # No need to pass an ID for singular resource
  end
end
