class LocationPreference < ApplicationRecord
  # Associations
  belongs_to :student_profile

  # Validations
  validates :location, allow_blank: true, length: { maximum: 20 }
end
