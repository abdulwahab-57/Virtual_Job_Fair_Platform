class Project < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  # validates :student_profile_id, presence: true
  validates :project_name, allow_blank: true, length: { maximum: 80 },
                           uniqueness: { scope: :student_profile_id, message: "already exists in your profile" }
  validates :description, allow_blank: true, length: { maximum: 450 }
end
