class InboxController < ApplicationController
  layout "private"
  before_action :authenticate_user!, :set_sidebar, :set_path

  def index
    @header_text = "Inbox"
    @conversations = current_user.conversations
                     .includes(:messages, sender: [ :student_profile, :recruiter_profile, :career_officer_profile ],
                               recipient: [ :student_profile, :recruiter_profile, :career_officer_profile ])
                     .by_most_recent
    @users = User.where.not(id: current_user.id)
                 .where.not(confirmed_at: nil)
                 .includes(:student_profile, :recruiter_profile, :career_officer_profile)
                 .order(:user_type, :full_name)

    # If a conversation_id is provided, load it as the selected conversation
    if params[:conversation_id].present?
      @selected_conversation = @conversations.find_by(id: params[:conversation_id])
      if @selected_conversation
        @message = Message.new
        # Mark messages as read
        @selected_conversation.messages.where(read: false).where.not(user_id: current_user.id).update_all(read: true)
      else
        # Conversation not found or user doesn't have access
        flash.now[:alert] = "The requested conversation could not be found."
      end
    end
  end

  private

  def set_sidebar
    # Set appropriate sidebar tabs based on user type
    case current_user.user_type
    when "student"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: student_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Job Fair Arena", icon: "video", path: student_job_fair_arena_index_path },
        { label: "Report", icon: "document", path: analytics_path }
      ]
    when "recruiter"
      # Do not set @sidebar_tabs here; let Recruiter::BaseController handle it.
    when "career_officer"
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: career_officer_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Student Profiles", icon: "users", path: career_officer_student_profiles_path },
        { label: "Job Fair Arena", icon: "video", path: career_officer_job_fair_arena_index_path },
        { label: "Meetings", icon: "calendar", path: career_officer_meetings_path },
        { label: "Analytics", icon: "chart-bar", path: analytics_path }
      ]
    end
  end

  def set_path
    # Set appropriate paths based on user type
    case current_user.user_type
    when "student"
      @home_path = student_dashboard_path
      @show_profile_path = student_profile_path(current_user.id)
      @edit_profile_path = edit_student_profile_path(current_user.id)
    when "recruiter"
      @home_path = recruiter_dashboard_path
      @show_profile_path = recruiter_profile_path(current_user.id)
      @edit_profile_path = edit_recruiter_profile_path(current_user.id)
    when "career_officer"
      @home_path = career_officer_dashboard_path
      @show_profile_path = career_officer_profile_path(current_user.id)
      @edit_profile_path = edit_career_officer_profile_path(current_user.id)
    end
  end
end
