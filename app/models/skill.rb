class Skill < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  validates :student_profile_id, presence: true
  validates :title, presence: true, length: { maximum: 100 }
  validates :skill_list, presence: true
end
