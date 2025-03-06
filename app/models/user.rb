class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Associations
  has_one :student_profile, dependent: :destroy, inverse_of: :user
  has_one :recruiter_profile, dependent: :destroy, inverse_of: :user
  has_one :career_officer_profile, dependent: :destroy, inverse_of: :user

  # Nested attributes
  accepts_nested_attributes_for :student_profile, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :recruiter_profile, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :career_officer_profile, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :full_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 100 }
  validates :user_type, presence: true, inclusion: { in: %w[student recruiter career_officer] }, on: :create
  validates :password, presence: true, length: { minimum: 8 }
  validates :password_confirmation, presence: true

  # Custom validation to ensure password and password_confirmation match
  validate :password_match
  validate :validate_profile, on: :create

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
end
