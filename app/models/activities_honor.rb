class ActivitiesHonor < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  validates :student_profile_id, presence: true
  validates :title, presence: true, length: { maximum: 100 }
  validates :organization, presence: true, length: { maximum: 100 }
end
