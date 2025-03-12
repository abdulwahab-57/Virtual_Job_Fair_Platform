class VirtualBoothCardComponent < ViewComponent::Base
  attr_reader :meeting

  def initialize(meeting:)
    @meeting = meeting
  end

  def status_badge_class
    if meeting.active?
      "bg-green-100 text-green-800"
    elsif meeting.scheduled?
      "bg-blue-100 text-blue-800"
    elsif meeting.ended?
      "bg-gray-100 text-gray-800"
    elsif meeting.cancelled?
      "bg-red-100 text-red-800"
    end
  end

  def status_text
    if meeting.active?
      "Active"
    elsif meeting.scheduled?
      "Scheduled"
    elsif meeting.ended?
      "Ended"
    elsif meeting.cancelled?
      "Cancelled"
    end
  end

  def time_display
    if meeting.active?
      "Started: #{time_ago_in_words(meeting.start_time)} ago"
    else
      "Starts: #{meeting.start_time.strftime("%b %d, %Y %I:%M %p")}"
    end
  end

  def action_path
    if meeting.active?
      Rails.application.routes.url_helpers.career_officer_job_fair_arena_path(meeting)
    else
      Rails.application.routes.url_helpers.career_officer_meeting_path(meeting)
    end
  end

  def action_text
    meeting.active? ? "Join Booth" : "View Details"
  end

  def action_class
    meeting.active? ? "bg-blue-500 hover:bg-blue-600" : "bg-gray-500 hover:bg-gray-600"
  end
end
