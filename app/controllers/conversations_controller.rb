class ConversationsController < ApplicationController
  layout "private"
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show ]
  before_action :set_sidebar, :set_path

  def index
    @header_text = "Conversations"
    redirect_to inbox_path
  end

  def show
    @header_text = "Conversation with #{@conversation.other_participant(current_user).full_name}"
    @message = Message.new

    # Mark all unread messages in this conversation as read
    @conversation.messages.where(read: false).where.not(user_id: current_user.id).update_all(read: true)
  end

  def create
    recipient = User.find(params[:recipient_id])

    # Use the get_or_create method to find or create a conversation
    conversation = Conversation.get_or_create(current_user.id, recipient.id)

    # Touch the conversation to update its timestamp
    conversation.touch if conversation.persisted?

    # Redirect to inbox with the conversation_id parameter instead of the conversation show page
    redirect_to inbox_path(conversation_id: conversation.id)
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
    # Check if the current user is part of this conversation
    unless @conversation.sender_id == current_user.id || @conversation.recipient_id == current_user.id
      redirect_to inbox_path, alert: "You don't have access to this conversation."
    end
  end

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
      @sidebar_tabs = [
        { label: "Home", icon: "home", path: recruiter_dashboard_path },
        { label: "Inbox", icon: "chat", path: inbox_path },
        { label: "Job Fair Arena", icon: "video", path: recruiter_job_fair_arena_index_path },
        { label: "GitHub Student Rankings", icon: "chart-bar", path: recruiter_github_analyzer_rankings_path },
        { label: "GitHub Skills Analysis", icon: "chart-bar", path: recruiter_github_analyzer_skills_path },
        { label: "GitHub Activity Timeline", icon: "chart-bar", path: recruiter_github_analyzer_activity_path },
        { label: "Analytics", icon: "chart-bar", path: "/analytics" }
      ]
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
