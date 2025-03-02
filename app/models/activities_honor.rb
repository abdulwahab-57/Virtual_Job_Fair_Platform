class ActivitiesHonor < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  # validates :student_profile_id, presence: true
  validates :title, allow_blank: true, length: { maximum: 100 }
  validates :organization, allow_blank: true, length: { maximum: 100 }
end
