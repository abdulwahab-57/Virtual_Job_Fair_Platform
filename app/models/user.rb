class User < ApplicationRecord
  # Enums
  enum role: { student: "student", recruiter: "recruiter", career_officer: "career_officer" }

  # Associations
  has_one :student_profile, dependent: :destroy
  has_one :recruiter_profile, dependent: :destroy
  has_one :career_officer_profile, dependent: :destroy

  # Validations
  validates :full_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 100 }
end
