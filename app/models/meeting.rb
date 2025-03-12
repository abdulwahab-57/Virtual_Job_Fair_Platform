class Meeting < ApplicationRecord
  # Associations
  has_many :meeting_participants, dependent: :destroy
  has_many :users, through: :meeting_participants

  # Validations
  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  # Scopes
  scope :upcoming, -> {
    Rails.logger.info("Finding upcoming meetings. Current time: #{Time.current.utc}")
    where("start_time > ?", Time.current.utc).order(start_time: :asc)
  }

  scope :ongoing, -> {
    Rails.logger.info("Finding ongoing meetings. Current time: #{Time.current.utc}")
    where("start_time <= ? AND end_time >= ?", Time.current.utc, Time.current.utc).order(start_time: :asc)
  }

  scope :past, -> {
    Rails.logger.info("Finding past meetings. Current time: #{Time.current.utc}")
    where("end_time < ?", Time.current.utc).order(start_time: :desc)
  }

  # Encrypt sensitive data
  attr_encrypted :zoom_meeting_password, key: ENV["ENCRYPTION_KEY"]

  # Status constants
  STATUSES = %w[scheduled started ended cancelled].freeze

  # Methods to check meeting status
  def scheduled?
    status == "scheduled"
  end

  def started?
    status == "started"
  end

  def ended?
    status == "ended"
  end

  def cancelled?
    status == "cancelled"
  end

  # Check if meeting is currently active
  def active?
    current_time = Time.current.utc
    start_time_utc = start_time.utc
    end_time_utc = end_time.utc

    Rails.logger.info("Checking if meeting is active:")
    Rails.logger.info("Current time (UTC): #{current_time}")
    Rails.logger.info("Start time (UTC): #{start_time_utc}")
    Rails.logger.info("End time (UTC): #{end_time_utc}")

    is_active = current_time.between?(start_time_utc, end_time_utc) && !cancelled?
    Rails.logger.info("Is meeting active? #{is_active}")

    is_active
  end

  # Get the host user
  def host
    User.find_by(id: host_id)
  end

  # Get all student participants
  def student_participants
    users.joins(:student_profile).distinct
  end

  # Get all recruiter participants
  def recruiter_participants
    users.joins(:recruiter_profile).distinct
  end

  # Get career officer participants
  def career_officer_participants
    users.joins(:career_officer_profile).distinct
  end

  # Add a participant to the meeting
  def add_participant(user, role = "attendee")
    meeting_participants.create(user: user, role: role)
  end

  # Remove a participant from the meeting
  def remove_participant(user)
    meeting_participants.find_by(user: user)&.destroy
  end

  # Check if a user is a participant
  def participant?(user)
    users.include?(user)
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
end
