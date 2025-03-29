class Interest < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  # validates :student_profile_id, presence: true
  validates :interest_list, allow_blank: true, length: { maximum: 80 }
end
