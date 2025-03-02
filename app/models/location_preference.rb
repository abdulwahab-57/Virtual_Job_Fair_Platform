class LocationPreference < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  # validates :student_profile_id, presence: true
  validates :location, allow_blank: true, length: { maximum: 50 }
  validates :preference_order, allow_blank: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1
            }
end
