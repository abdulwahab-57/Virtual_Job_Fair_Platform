class EnhancedAnalyticsController < ApplicationController
  include EnhancedAnalyticsHelper
  include AnalyticsHelper # Include existing helper to reuse calculate_profile_completion

  before_action :authenticate_user!
  before_action :set_sidebar_and_paths
  layout "private"

  def student_dashboard
    @student = User.find_by(id: params[:id])
    authorize_student_view!(@student)

    begin
      @analytics_data = student_additional_analytics(@student)
      @skills_breakdown = @analytics_data[:skills_breakdown]
      @education_timeline = @analytics_data[:education_timeline]
    rescue => e
      Rails.logger.error "Error in student_dashboard: #{e.message}"
      @analytics_data = {
        education_timeline: [],
        skills_breakdown: { labels: [], values: [] },
        projects_count: 0,
        activities_count: 0,
        interests_count: 0,
        location_preferences_count: 0
      }
      @skills_breakdown = { labels: [], values: [] }
      @education_timeline = []
      flash.now[:alert] = "There was an issue loading some analytics data."
    end
  end

  def recruiter_dashboard
    @recruiter = User.find_by(id: params[:id])
    authorize_recruiter_view!(@recruiter)

    begin
      @analytics_data = recruiter_additional_analytics(@recruiter)
      @industry_data = industry_distribution_data
    rescue => e
      Rails.logger.error "Error in recruiter_dashboard: #{e.message}"
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

  def career_officer_dashboard
    begin
      @top_skills = top_skills_data
      @education_timeline = education_timeline_data
      @student_statuses = student_status_distribution
      @completion_trends = profile_completion_distribution
    rescue => e
      Rails.logger.error "Error in career_officer_dashboard: #{e.message}"
      @top_skills = { labels: [], values: [] }
      @education_timeline = { labels: [], values: [] }
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
        { label: "Student Profiles", icon: "users", path: "#" },
        { label: "Job Fair Arena", icon: "video", path: "#" },
        { label: "Meetings", icon: "calendar", path: "#" },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
      @home_path = student_dashboard_path
    when "recruiter"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: recruiter_dashboard_path },
        { label: "Virtual Booth", icon: "video", path: "#" },
        { label: "Student Profiles", icon: "users", path: "#" },
        { label: "Meetings", icon: "calendar", path: "#" },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
      @home_path = recruiter_dashboard_path
    when "career_officer"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: career_officer_dashboard_path },
        { label: "Student Profiles", icon: "users", path: career_officer_student_profiles_path },
        { label: "Recruiter Profiles", icon: "briefcase", path: "#" },
        { label: "Job Fair Arena", icon: "video", path: "#" },
        { label: "Meetings", icon: "calendar", path: "#" },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
      @home_path = career_officer_dashboard_path
    end
    @header_text = "Enhanced Analytics Dashboard"
  end

  # Authorization methods (copied from analytics_controller to avoid modification)
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
