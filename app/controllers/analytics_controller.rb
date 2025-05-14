class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sidebar_and_paths
  layout "private"

  def index
    @user_type = current_user.user_type

    respond_to do |format|
      format.html
      format.json { render json: analytics_data }
    end
  end

  def student_analytics
    @student = User.find_by(id: params[:id])
    authorize_student_view!(@student)
  end

  def recruiter_analytics
    @recruiter = User.find_by(id: params[:id])
    authorize_recruiter_view!(@recruiter)
  end

  def dashboard
    # General dashboard view
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
        { label: "Report", icon: "document", path: analytics_path }
      ]
      @home_path = student_dashboard_path
      @header_text = "Report Dashboard"
    when "recruiter"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: recruiter_dashboard_path },
        { label: "Virtual Booth", icon: "video", path: "#" },
        { label: "Student Profiles", icon: "users", path: "#" },
        { label: "Meetings", icon: "calendar", path: "#" },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
      @home_path = recruiter_dashboard_path
      @header_text = "Analytics Dashboard"
    when "career_officer"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: career_officer_dashboard_path },
        { label: "Student Profiles", icon: "users", path: career_officer_student_profiles_path },
        { label: "Job Fair Arena", icon: "video", path: "#" },
        { label: "Meetings", icon: "calendar", path: "#" },
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
