class Project < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  validates :student_profile_id, presence: true
  validates :project_name, presence: true, length: { maximum: 100 }
  validates :description, presence: true
end
