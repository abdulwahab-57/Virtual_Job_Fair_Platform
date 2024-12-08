class Interest < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  validates :student_profile_id, presence: true
  validates :interest_list, presence: true
end
