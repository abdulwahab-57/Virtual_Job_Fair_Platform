class User < ApplicationRecord
  attr_accessor :career_officer_confirmed # Virtual attribute to track career officer confirmation

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
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :password_confirmation, presence: true, on: :create

  # Custom validation to ensure password and password_confirmation match
  validate :password_match
  validate :validate_profile, on: :create
  validate :validate_email_domain, on: :create

  # Check if the user is a recruiter
  def recruiter?
    user_type == "recruiter"
  end

  # Check if the user is a student
  def student?
    user_type == "student"
  end

  # Check if the user is a career officer
  def career_officer?
    user_type == "career_officer"
  end

  # Override Devise's `active_for_authentication?` method
  def active_for_authentication?
    if recruiter?
      # Recruiter can only log in if both recruiter and career officer have confirmed
      super && career_officer_confirmed?
    else
      super
    end
  end

  # Custom confirmation logic for recruiters
  def confirm!
    if recruiter? && !confirmed?
      # If the recruiter confirms, mark them as confirmed
      self.confirmed_at = Time.now
      save

      # Send confirmation request to the career officer
      send_career_officer_confirmation_request
    else
      # Default confirmation logic for other user types
      super
    end
  end

  # Method to handle career officer's confirmation
  def career_officer_confirm!
    if recruiter? && confirmed?
      self.career_officer_confirmed = true
      save

      # Notify the recruiter that their account is fully confirmed
      send_confirmation_notification if fully_confirmed?
    end
  end

  # Check if both recruiter and career officer have confirmed
  def fully_confirmed?
    confirmed? && career_officer_confirmed?
  end

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

    # Move this method outside the private block
    def send_career_officer_confirmation_request
      career_officers = User.where(user_type: "career_officer")
                           .where.not(confirmed_at: nil)

      career_officers.each do |officer|
        ApplicationMailer.career_officer_approval_request(self, officer).deliver_later
      end
    end

    def career_officer_confirmed?
      # Check if the career officer has confirmed
      career_officer_confirmed == true
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
