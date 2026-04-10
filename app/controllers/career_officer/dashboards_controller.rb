class CareerOfficer::DashboardsController < CareerOfficer::BaseController
  def index
    @header_text = "Home"
    @total_students = User.where(user_type: "student").count
    @total_recruiters = User.where(user_type: "recruiter").count
    @jobs_count = defined?(Job) ? Job.count : 0
    @student_status_distribution = AnalyticsService.student_status_distribution
    @student_completion_distribution = AnalyticsService.completion_distribution(User.where(user_type: "student").to_a)
  end
end
