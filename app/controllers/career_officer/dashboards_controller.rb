class CareerOfficer::DashboardsController < CareerOfficer::BaseController
  include EnhancedAnalyticsHelper
  include AnalyticsHelper

  def index
    @header_text = "Home"
    @total_students = User.where(user_type: "student").count
    @total_recruiters = User.where(user_type: "recruiter").count
    @jobs_count = Object.const_defined?("Job") ? Job.count : 0
    @student_status_distribution = student_status_distribution
    @student_completion_distribution = completion_distribution(User.where(user_type: "student").to_a)
  end
end
