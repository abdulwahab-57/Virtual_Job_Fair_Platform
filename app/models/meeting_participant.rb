class MeetingParticipant < ApplicationRecord
  belongs_to :meeting
  belongs_to :user

  # Role constants
  ROLES = %w[host co-host attendee].freeze

  # Validations
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :meeting_id, message: "is already a participant in this meeting" }

  # Scopes
  scope :hosts, -> { where(role: "host") }
  scope :co_hosts, -> { where(role: "co-host") }
  scope :attendees, -> { where(role: "attendee") }

  # Check if participant is a host
  def host?
    role == "host"
  end

  # Check if participant is a co-host
  def co_host?
    role == "co-host"
  end

  # Check if participant is an attendee
  def attendee?
    role == "attendee"
  end
end
