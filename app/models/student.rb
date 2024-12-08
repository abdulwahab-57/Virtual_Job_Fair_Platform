class Student < ApplicationRecord
  has_one :user, as: :profile
  validates :roll_number, presence: true
  validates :graduation_year, presence: true
end
