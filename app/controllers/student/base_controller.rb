class Student::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private
  def set_path
    @home_path = student_path
    @profile_path = student_profile_path(12)
  end
end
