# app/models/career_office.rb
class CareerOffice < ApplicationRecord
  has_one :user, as: :profile
  validates :institution_name, presence: true
  validates :department, presence: true
end
