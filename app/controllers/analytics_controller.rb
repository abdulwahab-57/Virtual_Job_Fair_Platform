class AnalyticsController < ApplicationController
  include EnhancedAnalyticsHelper
  before_action :authenticate_user!
  before_action :set_sidebar_and_paths
  layout "private"

  def index
    @user_type = current_user.user_type

    # Load enhanced analytics data based on user type
    case current_user.user_type
    when "student"
      @analytics_data = student_additional_analytics(current_user)
      @education_timeline = @analytics_data[:education_timeline]
    when "recruiter"
      @analytics_data = recruiter_additional_analytics(current_user)
      @industry_data = industry_distribution_data
    when "career_officer"
      @student_statuses = student_status_distribution
      @completion_trends = profile_completion_distribution
    end

    respond_to do |format|
      format.html
      format.json { render json: analytics_data }
    end
  end

  def student_analytics
    @student = User.find_by(id: params[:id])
    authorize_student_view!(@student)

    begin
      @analytics_data = student_additional_analytics(@student)
      @education_timeline = @analytics_data[:education_timeline]
    rescue => e
      Rails.logger.error "Error in student_analytics: #{e.message}"
      @analytics_data = {
        education_timeline: [],
        projects_count: 0,
        activities_count: 0,
        interests_count: 0,
        location_preferences_count: 0
      }
      @education_timeline = []
      flash.now[:alert] = "There was an issue loading some analytics data."
    end
  end

  def recruiter_analytics
    @recruiter = User.find_by(id: params[:id])
    authorize_recruiter_view!(@recruiter)

    begin
      @analytics_data = recruiter_additional_analytics(@recruiter)
      @industry_data = industry_distribution_data
    rescue => e
      Rails.logger.error "Error in recruiter_analytics: #{e.message}"
      @analytics_data = {
        company_info: {
          company_name: @recruiter.recruiter_profile&.company_name,
          industry: @recruiter.recruiter_profile&.industry,
          website: @recruiter.recruiter_profile&.company_website,
          employee_count: @recruiter.recruiter_profile&.employee_count
        },
        potential_matches: 0,
        company_industry_position: nil
      }
      @industry_data = { labels: [], values: [] }
      flash.now[:alert] = "There was an issue loading some analytics data."
    end
  end

  def dashboard
    # Load enhanced analytics data for career officer dashboard
    begin
      # No longer loading @top_skills and @education_timeline
      @student_statuses = student_status_distribution
      @completion_trends = profile_completion_distribution
    rescue => e
      Rails.logger.error "Error in dashboard: #{e.message}"
      @student_statuses = { labels: [ "No Data" ], values: [ 0 ] }
      @completion_trends = { students: [ 0, 0, 0, 0 ], recruiters: [ 0, 0, 0, 0 ] }
      flash.now[:alert] = "There was an issue loading some analytics data."
    end
  end

  def api_chart_data
    begin
      case params[:chart_type]
      when "skills"
        render json: top_skills_data
      when "education"
        render json: education_timeline_data
      when "industry"
        render json: industry_distribution_data
      when "status"
        render json: student_status_distribution
      when "completion"
        render json: profile_completion_distribution
      else
        render json: { error: "Unknown chart type" }, status: 400
      end
    rescue => e
      Rails.logger.error "Error in api_chart_data: #{e.message}"
      render json: { error: "An error occurred while processing the chart data" }, status: 500
    end
  end

  private

  def set_sidebar_and_paths
    case current_user.user_type
    when "student"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: student_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Job Fair Arena", icon: "video", path: student_job_fair_arena_index_path },
        { label: "Report", icon: "document", path: analytics_path }
      ]
      @home_path = student_dashboard_path
      @header_text = "Report Dashboard"
    when "recruiter"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: recruiter_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Job Fair Arena", icon: "video", path: recruiter_job_fair_arena_index_path },
        { label: "GitHub Student Rankings", icon: "chart-bar", path: recruiter_github_analyzer_rankings_path },
        { label: "GitHub Skills Analysis", icon: "chart-bar", path: recruiter_github_analyzer_skills_path },
        { label: "GitHub Activity Timeline", icon: "chart-bar", path: recruiter_github_analyzer_activity_path },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
      @home_path = recruiter_dashboard_path
      @header_text = "Analytics Dashboard"
    when "career_officer"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: career_officer_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Student Profiles", icon: "users", path: career_officer_student_profiles_path },
        { label: "Job Fair Arena", icon: "video", path: career_officer_job_fair_arena_index_path },
        { label: "Meetings", icon: "calendar", path: career_officer_meetings_path },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
      @home_path = career_officer_dashboard_path
      @header_text = "Analytics Dashboard"
    end
  end

  def analytics_data
    case current_user.user_type
    when "student"
      student_analytics_data(current_user)
    when "recruiter"
      recruiter_analytics_data(current_user)
    when "career_officer"
      career_officer_analytics_data
    else
      {}
    end
  end

  def student_analytics_data(student)
    {
      profile_completion: calculate_profile_completion(student),
      skills: student.student_profile&.skills&.count || 0,
      educations: student.student_profile&.educations&.count || 0
    }
  end

  def recruiter_analytics_data(recruiter)
    {
      profile_completion: calculate_profile_completion(recruiter)
    }
  end

  def career_officer_analytics_data
    {
      total_students: User.where(user_type: "student").count,
      total_recruiters: User.where(user_type: "recruiter").count
    }
  end

  def calculate_profile_completion(user)
    case user.user_type
    when "student"
      profile = user.student_profile
      return 0 unless profile

      # Calculate completion percentage based on filled fields
      fields = [
        profile.date_of_birth.present?,
        profile.email_personal.present?,
        profile.phone_number.present?,
        profile.address.present?,
        profile.linkedin_url.present?,
        user.profile_picture.attached?,
        profile.educations.any?,
        profile.projects.any?,
        profile.skills.any?
      ]

      completed = fields.count(true)
      (completed.to_f / fields.size * 100).round
    when "recruiter"
      profile = user.recruiter_profile
      return 0 unless profile

      # Calculate completion percentage based on filled fields
      fields = [
        profile.company_name.present?,
        profile.industry.present?,
        profile.about_company.present?,
        profile.office_location.present?,
        profile.company_email.present?,
        profile.company_website.present?,
        profile.employee_count.present?
      ]

      completed = fields.count(true)
      (completed.to_f / fields.size * 100).round
    else
      0
    end
  end

  # Authorization methods
  def authorize_student_view!(student)
    unless student && (current_user.career_officer? || current_user.id == student.id)
      redirect_to root_path, alert: "Unauthorized access"
    end
  end

  def authorize_recruiter_view!(recruiter)
    unless recruiter && (current_user.career_officer? || current_user.id == recruiter.id)
      redirect_to root_path, alert: "Unauthorized access"
    end
  end
end
