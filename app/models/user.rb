class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Associations
  has_one :student_profile, dependent: :destroy, inverse_of: :user
  has_one :recruiter_profile, dependent: :destroy, inverse_of: :user
  has_one :career_officer_profile, dependent: :destroy, inverse_of: :user
  has_one :zoom_credential, dependent: :destroy
  has_many :meetings, dependent: :destroy

  # Active storage association
  has_one_attached :profile_picture

  ALLOWED_PROFILE_PICTURE_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  validate :acceptable_profile_picture

  def acceptable_profile_picture
    return unless profile_picture.attached? && profile_picture.changed?

    unless ALLOWED_PROFILE_PICTURE_TYPES.include?(profile_picture.content_type)
      type_label = profile_picture.content_type.split("/").last.upcase
      errors.add(:profile_picture,
        "must be a JPEG, PNG, GIF, or WebP image (you uploaded a #{type_label} file)")
    end
  end

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
    return if confirmed? # Prevent duplicate confirmations

    self.confirmed_at = Time.current
    save

    send_career_officer_confirmation_request if recruiter?
  end

  # Method to handle career officer's confirmation
  def career_officer_confirm!
    return unless recruiter? && confirmed?

    update(career_officer_confirmed: true)

    send_confirmation_notification if fully_confirmed?
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

  # Send confirmation request to career officers
  def send_career_officer_confirmation_request
    Rails.logger.info "Career officer confirmation request triggered for recruiter: #{email}"

    career_officers = User.where(user_type: "career_officer")
                          .where.not(confirmed_at: nil)

    if career_officers.empty?
      Rails.logger.warn "No confirmed career officers found!"
    end

    career_officers.each do |officer|
      Rails.logger.info "Sending email to: #{officer.email}"
      ApplicationMailer.career_officer_approval_request(self, officer).deliver_later
    end
  end

  # Check if the career officer has confirmed
  def career_officer_confirmed?
    self[:career_officer_confirmed] == true
  end

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
    if user_type.in?(%w[student]) && !email.end_with?("@cfd.nu.edu.pk")
      errors.add(:email, "must be a valid @cfd.nu.edu.pk email address")
    end
  end
end
