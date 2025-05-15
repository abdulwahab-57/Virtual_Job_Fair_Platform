# frozen_string_literal: true

class VirtualBoothComponent < ViewComponent::Base
  attr_reader :meeting

  def initialize(meeting:)
    @meeting = meeting
  end


  def formatted_time
    return "Time not specified" unless meeting["start_time"]

    start_time = Time.parse(meeting["start_time"])
    start_time.strftime("%b %d, %Y at %I:%M %p")
  end

  def meeting_duration
    return "Duration not specified" unless meeting["duration"]

    hours = meeting["duration"] / 60
    minutes = meeting["duration"] % 60

    duration_str = []
    duration_str << "#{hours} hr" if hours > 0
    duration_str << "#{minutes} min" if minutes > 0

    duration_str.join(" ")
  end

  def truncated_topic
    meeting["topic"].length > 50 ? "#{meeting["topic"][0..47]}..." : meeting["topic"]
  end


  def meeting_status
    Time.parse(meeting["start_time"]) > Time.now ? "Upcoming" : "In Progress"
  end
end
