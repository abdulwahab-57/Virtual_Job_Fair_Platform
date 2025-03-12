class Recruiter::VirtualBoothController < Recruiter::BaseController
  before_action :set_meeting, only: [ :show ]
  before_action :check_participant, only: [ :show ]

  def index
    @header_text = "Virtual Booth"

    # Log current time for debugging
    Rails.logger.info("Index - Current time: #{Time.current.utc}")

    # Get upcoming meetings
    @upcoming_meetings = current_user.meetings.upcoming.where(status: "scheduled")
    Rails.logger.info("Index - Upcoming meetings count: #{@upcoming_meetings.count}")
    @upcoming_meetings.each do |meeting|
      Rails.logger.info("Index - Upcoming meeting: #{meeting.id}, start: #{meeting.start_time.utc}, end: #{meeting.end_time.utc}")
    end

    # Get active meetings
    @active_meetings = current_user.meetings.ongoing.where(status: "started")
    Rails.logger.info("Index - Active meetings count: #{@active_meetings.count}")
    @active_meetings.each do |meeting|
      Rails.logger.info("Index - Active meeting: #{meeting.id}, start: #{meeting.start_time.utc}, end: #{meeting.end_time.utc}")
    end

    # Get past meetings
    @past_meetings = current_user.meetings.past.where(status: [ "ended", "cancelled" ])
    Rails.logger.info("Index - Past meetings count: #{@past_meetings.count}")
  end

  def show
    @header_text = "Meeting Details"

    # Log times for debugging
    Rails.logger.info("Meeting show - Current time: #{Time.current.utc}")
    Rails.logger.info("Meeting show - Meeting start time: #{@meeting.start_time.utc}")
    Rails.logger.info("Meeting show - Meeting end time: #{@meeting.end_time.utc}")
    Rails.logger.info("Meeting show - Meeting active?: #{@meeting.active?}")

    unless @meeting.active?
      if @meeting.start_time.utc > Time.current.utc
        @time_until_start = distance_of_time_in_words(Time.current.utc, @meeting.start_time.utc)
        Rails.logger.info("Meeting show - Time until start: #{@time_until_start}")
      elsif @meeting.end_time.utc < Time.current.utc
        flash.now[:notice] = "This meeting has ended."
        Rails.logger.info("Meeting show - Meeting has ended")
      elsif @meeting.cancelled?
        flash.now[:alert] = "This meeting has been cancelled."
        Rails.logger.info("Meeting show - Meeting has been cancelled")
      end
    end
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:id])
  end

  def check_participant
    unless @meeting.participant?(current_user)
      redirect_to recruiter_virtual_booth_index_path, alert: "You are not a participant in this meeting."
    end
  end
end
