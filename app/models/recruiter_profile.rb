class RecruiterProfile < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :company_name, presence: true
  validates :company_website, allow_blank: true,
            format: { with: /\Ahttps?:\/\/.+\z/ }
end
