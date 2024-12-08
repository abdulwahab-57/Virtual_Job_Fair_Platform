class RecruiterProfile < ApplicationRecord
  # Enums
  enum employee_count: {
    small: "1-50",
    medium: "51-200",
    large: "201-500",
    xlarge: "501-1000",
    enterprise: "1001+"
  }

  # Associations
  belongs_to :user
  has_many :hiring_team_members, dependent: :destroy
  has_many :gallery_images, dependent: :destroy

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :company_name, presence: true
  validates :company_website, allow_blank: true,
            format: { with: /\Ahttps?:\/\/.+\z/ }
end
