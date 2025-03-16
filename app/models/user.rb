class User < ApplicationRecord
  include UserType
  include ZoomIntegration

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
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 100 }
  validates :user_type, presence: true, inclusion: { in: %w[student recruiter career_officer] }, on: :create
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :password_confirmation, presence: true, on: :create

  # Custom validation to ensure password and password_confirmation match
  validate :password_match
  validate :validate_profile, on: :create
  validate :validate_email_domain, on: :create

  # Add these methods for approval tokens
  def generate_approval_token
    Rails.application.message_verifier(:approve_recruiter).generate(id)
  end

  def self.find_by_approval_token(token)
    id = Rails.application.message_verifier(:approve_recruiter).verify(token)
    find(id)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  private

  def password_match
    errors.add(:password_confirmation, "doesn't match Password") if password != password_confirmation
  end

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

  def validate_email_domain
    if user_type.in?(%w[student career_officer]) && !email.end_with?("@cfd.nu.edu.pk")
      errors.add(:email, "must be a valid @cfd.nu.edu.pk email address")
    end
  end
end
