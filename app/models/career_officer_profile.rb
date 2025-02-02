class CareerOfficerProfile < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :designation, presence: true
  validates :phone_number, allow_blank: true,
            format: { with: /\A\+?[\d\s-]{10,20}\z/ }
end
