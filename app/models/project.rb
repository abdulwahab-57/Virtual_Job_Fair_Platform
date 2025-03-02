class Project < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  # validates :student_profile_id, presence: true
  validates :project_name, allow_blank: true, length: { maximum: 100 }
  validates :description, allow_blank: true, length: { maximum: 500 }
end
