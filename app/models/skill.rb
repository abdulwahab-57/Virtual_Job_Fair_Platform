class Skill < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  # validates :student_profile_id, presence: true
  validates :title, allow_blank: true, length: { maximum: 100 }
  validates :skill_list, allow_blank: true, length: { maximum: 200 }
end
