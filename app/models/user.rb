class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Associations
  has_one :student_profile, dependent: :destroy, inverse_of: :user
  has_one :recruiter_profile, dependent: :destroy, inverse_of: :user
  has_one :career_officer_profile, dependent: :destroy, inverse_of: :user
  has_one :zoom_credential, dependent: :destroy
  has_many :meeting_participants, dependent: :destroy
  has_many :meetings, through: :meeting_participants
  has_many :hosted_meetings, class_name: "Meeting", foreign_key: "host_id"

  # Active storage association
  has_one_attached :profile_picture

  # Nested attributes
  accepts_nested_attributes_for :student_profile, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :recruiter_profile, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :career_officer_profile, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :full_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 100 }
  validates :user_type, presence: true, inclusion: { in: %w[student recruiter career_officer] }, on: :create

  # Validate associated profile based on user_type
  validate :validate_profile, on: :create

  # Check if user is a student
  def student?
    user_type == "student"
  end

  # Check if user is a recruiter
  def recruiter?
    user_type == "recruiter"
  end

  # Check if user is a career officer
  def career_officer?
    user_type == "career_officer"
  end

  # Check if user has Zoom credentials
  def has_zoom_credentials?
    zoom_credential.present?
  end

  # Get valid Zoom access token
  def zoom_access_token
    return nil unless has_zoom_credentials?

    Rails.logger.info("User #{id} requesting Zoom access token")
    token = zoom_credential.valid_access_token

    if token.blank?
      Rails.logger.error("Failed to get valid access token for user #{id}")
      return nil
    end

    token
  end

  private

  def validate_profile
    case user_type
    when "student"
      errors.add(:base, "Student profile is required") if student_profile.nil?
    when "recruiter"
      errors.add(:base, "Recruiter profile is required") if recruiter_profile.nil?
    when "career_officer"
      errors.add(:base, "Career officer profile is required") if career_officer_profile.nil?
    end
  end
end
