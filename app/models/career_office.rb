# app/models/career_office.rb
class CareerOffice < ApplicationRecord
  has_one :user, as: :profile
end
