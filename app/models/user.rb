class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Add user type validation
  validates :user_type, presence: true,
            inclusion: { in: %w[student recruiter career_office] }

  # Polymorphic association for profiles
  belongs_to :profile, polymorphic: true, optional: true

  # Nested attributes for profiles
  accepts_nested_attributes_for :profile
end
