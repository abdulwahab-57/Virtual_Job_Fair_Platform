module EnhancedAnalyticsHelper
  # View-layer delegates — computation lives in AnalyticsService.
  # These allow templates to call the methods directly without knowing
  # about the service layer.

  def top_skills_data(limit = 10)
    AnalyticsService.top_skills_data(limit)
  end

  def education_timeline_data
    AnalyticsService.education_timeline_data
  end

  def industry_distribution_data
    AnalyticsService.industry_distribution_data
  end

  def student_status_distribution
    AnalyticsService.student_status_distribution
  end

  def profile_completion_distribution
    AnalyticsService.profile_completion_distribution
  end

  def completion_distribution(users)
    AnalyticsService.completion_distribution(users)
  end

  def student_additional_analytics(student)
    AnalyticsService.student_additional_analytics(student)
  end

  def student_education_timeline(student)
    AnalyticsService.student_education_timeline(student)
  end

  def recruiter_additional_analytics(recruiter)
    AnalyticsService.recruiter_additional_analytics(recruiter)
  end

  def calculate_student_matches(recruiter)
    AnalyticsService.calculate_student_matches(recruiter)
  end

  def industry_position(recruiter)
    AnalyticsService.industry_position(recruiter)
  end
end
