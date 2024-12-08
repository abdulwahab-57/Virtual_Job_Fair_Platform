class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  belongs_to :profile, polymorphic: true, optional: true

  # Adding validations for basic user info
  validates :phone_number, presence: true
  validates :full_name, presence: true
  accepts_nested_attributes_for :profile # This allows nested attributes for the profile (Student, Recruiter, CareerOffice)
end
