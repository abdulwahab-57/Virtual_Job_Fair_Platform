class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Associations
  has_one :student_profile, dependent: :destroy
  has_one :recruiter_profile, dependent: :destroy
  has_one :career_officer_profile, dependent: :destroy

  # Validations
  validates :full_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 100 }

  # Add user type validation
  validates :user_type, presence: true,
            inclusion: { in: %w[student recruiter career_office] }
end
