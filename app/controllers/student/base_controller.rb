class Student::BaseController < ApplicationController
  layout "private"
  before_action :set_path

  private
  def set_path
    @home_path = student_path
    @show_profile_path = student_profile_path(1)
    @edit_profile_path = edit_student_profile_path(1)
  end
end
