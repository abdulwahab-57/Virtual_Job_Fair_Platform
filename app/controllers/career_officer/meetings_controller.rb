class CareerOfficer::MeetingsController < CareerOfficer::BaseController
  before_action :set_meeting, only: [ :show, :edit, :update, :destroy, :add_participant, :remove_participant, :start, :end, :cancel ]
  before_action :check_zoom_credentials, only: [ :new, :create, :update, :start ]
  before_action :initialize_user_lists, only: [ :show, :new, :edit ]

  def index
    @header_text= "Meetings"
    @meetings = Meeting.all.order(start_time: :desc)
  end

  def show
    @header_text = "Meeting Details"
    # User lists are now initialized in the before_action
  end

  def new
    @header_text= "New Meeting"
    @meeting = Meeting.new
    # User lists are now initialized in the before_action
  end

  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.host_id = current_user.id
    @meeting.status = "scheduled"

    # Log the time for debugging
    Rails.logger.info("Meeting start time from form (raw): #{params[:meeting][:start_time]}")
    Rails.logger.info("Meeting end time from form (raw): #{params[:meeting][:end_time]}")

    # The browser sends local time (PKT) without timezone info
    # Convert from PKT to UTC by subtracting 5 hours
    if @meeting.start_time.present?
      @meeting.start_time = @meeting.start_time - 5.hours
      Rails.logger.info("Meeting start time after PKT->UTC conversion: #{@meeting.start_time}")
    end

    if @meeting.end_time.present?
      @meeting.end_time = @meeting.end_time - 5.hours
      Rails.logger.info("Meeting end time after PKT->UTC conversion: #{@meeting.end_time}")
    end

    Rails.logger.info("Meeting start time formatted: #{@meeting.start_time&.strftime('%Y-%m-%d %I:%M %p')}")
    Rails.logger.info("Meeting start time hour (24-hour): #{@meeting.start_time&.hour}")
    Rails.logger.info("Meeting start time UTC: #{@meeting.start_time&.utc}")

    if @meeting.save
      # Add the current user as a host
      @meeting.add_participant(current_user, "host")

      # Add selected participants
      add_selected_participants

      # Create Zoom meeting
      zoom_service = ZoomService.new(current_user)
      result = zoom_service.create_meeting(@meeting)

      # Always redirect to index path, but with different notices based on result
      if result[:success]
        redirect_to career_officer_meetings_path, notice: "Meeting was successfully created."
      else
        redirect_to career_officer_meetings_path, alert: "Meeting was saved but failed to create Zoom meeting: #{result[:error]}"
      end
    else
      @students = User.joins(:student_profile)
      @recruiters = User.joins(:recruiter_profile)
      @header_text= "New Meeting"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @header_text = "Edit Meeting"
    # User lists are now initialized in the before_action
  end

  def update
    # Log the time for debugging
    Rails.logger.info("Meeting start time from form (raw): #{params[:meeting][:start_time]}")
    Rails.logger.info("Meeting end time from form (raw): #{params[:meeting][:end_time]}")

    # Create a copy of the params to modify
    meeting_params_with_timezone = meeting_params.dup

    # Convert from PKT to UTC by subtracting 5 hours
    if meeting_params_with_timezone[:start_time].present?
      meeting_params_with_timezone[:start_time] = Time.zone.parse(meeting_params_with_timezone[:start_time].to_s) - 5.hours
      Rails.logger.info("Meeting start time after PKT->UTC conversion: #{meeting_params_with_timezone[:start_time]}")
    end

    if meeting_params_with_timezone[:end_time].present?
      meeting_params_with_timezone[:end_time] = Time.zone.parse(meeting_params_with_timezone[:end_time].to_s) - 5.hours
      Rails.logger.info("Meeting end time after PKT->UTC conversion: #{meeting_params_with_timezone[:end_time]}")
    end

    if @meeting.update(meeting_params_with_timezone)
      # Log the updated time
      Rails.logger.info("Updated meeting start time: #{@meeting.start_time}")
      Rails.logger.info("Updated meeting start time formatted: #{@meeting.start_time&.strftime('%Y-%m-%d %I:%M %p')}")
      Rails.logger.info("Updated meeting start time hour (24-hour): #{@meeting.start_time&.hour}")
      Rails.logger.info("Updated meeting start time UTC: #{@meeting.start_time&.utc}")

      # Update participants
      update_participants

      # Update Zoom meeting
      zoom_service = ZoomService.new(current_user)
      result = zoom_service.update_meeting(@meeting)

      # Always redirect to index path, but with different notices based on result
      if result[:success]
        redirect_to career_officer_meetings_path, notice: "Meeting was successfully updated."
      else
        redirect_to career_officer_meetings_path, alert: "Meeting was saved but failed to update Zoom meeting: #{result[:error]}"
      end
    else
      @students = User.joins(:student_profile)
      @recruiters = User.joins(:recruiter_profile)
      @header_text = "Edit Meeting"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Delete Zoom meeting
    zoom_service = ZoomService.new(current_user)
    result = zoom_service.delete_meeting(@meeting)

    @meeting.destroy
    redirect_to career_officer_meetings_path, notice: "Meeting was successfully deleted."
  end

  def add_participant
    user = User.find(params[:user_id])
    role = user.career_officer? ? "co-host" : "attendee"

    if @meeting.add_participant(user, role)
      redirect_to career_officer_meeting_path(@meeting), notice: "Participant was successfully added."
    else
      redirect_to career_officer_meeting_path(@meeting), alert: "Failed to add participant."
    end
  end

  def remove_participant
    user = User.find(params[:user_id])

    if @meeting.remove_participant(user)
      redirect_to career_officer_meeting_path(@meeting), notice: "Participant was successfully removed."
    else
      redirect_to career_officer_meeting_path(@meeting), alert: "Failed to remove participant."
    end
  end

  def start
    @meeting.update(status: "started")
    redirect_to career_officer_meeting_path(@meeting), notice: "Meeting has been started."
  end

  def end
    @meeting.update(status: "ended")
    redirect_to career_officer_meeting_path(@meeting), notice: "Meeting has been ended."
  end

  def cancel
    @meeting.update(status: "cancelled")

    # Cancel Zoom meeting
    zoom_service = ZoomService.new(current_user)
    zoom_service.delete_meeting(@meeting)

    redirect_to career_officer_meeting_path(@meeting), notice: "Meeting has been cancelled."
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:title, :description, :start_time, :end_time)
  end

  def check_zoom_credentials
    unless current_user.has_zoom_credentials?
      redirect_to zoom_auth_path, alert: "You need to connect your Zoom account first."
    end
  end

  def add_selected_participants
    # Add selected students
    if params[:student_ids].present?
      params[:student_ids].each do |student_id|
        student = User.find(student_id)
        @meeting.add_participant(student, "attendee")
      end
    end

    # Add selected recruiters
    if params[:recruiter_ids].present?
      params[:recruiter_ids].each do |recruiter_id|
        recruiter = User.find(recruiter_id)
        @meeting.add_participant(recruiter, "attendee")
      end
    end
  end

  def update_participants
    # Get current participants (excluding host and career officers)
    current_student_ids = @meeting.student_participants.pluck(:id)
    current_recruiter_ids = @meeting.recruiter_participants.pluck(:id)

    # Get selected participants
    selected_student_ids = params[:student_ids].present? ? params[:student_ids].map(&:to_i) : []
    selected_recruiter_ids = params[:recruiter_ids].present? ? params[:recruiter_ids].map(&:to_i) : []

    # Remove participants that are no longer selected
    (current_student_ids - selected_student_ids).each do |student_id|
      @meeting.remove_participant(User.find(student_id))
    end

    (current_recruiter_ids - selected_recruiter_ids).each do |recruiter_id|
      @meeting.remove_participant(User.find(recruiter_id))
    end

    # Add new participants
    (selected_student_ids - current_student_ids).each do |student_id|
      student = User.find(student_id)
      @meeting.add_participant(student, "attendee")
    end

    (selected_recruiter_ids - current_recruiter_ids).each do |recruiter_id|
      recruiter = User.find(recruiter_id)
      @meeting.add_participant(recruiter, "attendee")
    end
  end

  def initialize_user_lists
    if action_name == "edit" || action_name == "update"
      # For edit view, include all students and recruiters
      @students = User.joins(:student_profile)
                     .select("users.*, student_profiles.id as profile_id")
                     .where(user_type: "student")
                     .order(:full_name)

      @recruiters = User.joins(:recruiter_profile)
                       .select("users.*, recruiter_profiles.id as profile_id, recruiter_profiles.company_name")
                       .where(user_type: "recruiter")
                       .order(:full_name)
    else
      # For show and new views, exclude current participants
      @students = User.joins(:student_profile)
                     .select("users.*, student_profiles.id as profile_id")
                     .where(user_type: "student")
                     .where.not(id: @meeting&.users&.pluck(:id) || [])
                     .order(:full_name)

      @recruiters = User.joins(:recruiter_profile)
                       .select("users.*, recruiter_profiles.id as profile_id, recruiter_profiles.company_name")
                       .where(user_type: "recruiter")
                       .where.not(id: @meeting&.users&.pluck(:id) || [])
                       .order(:full_name)
    end

    # Debug information
    Rails.logger.debug "Students loaded: #{@students.to_a.inspect}"
    Rails.logger.debug "Recruiters loaded: #{@recruiters.to_a.inspect}"
  end
end
