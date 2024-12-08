# app/models/recruiter.rb
class Recruiter < ApplicationRecord
  has_one :user, as: :profile
  validates :company_name, presence: true
  validates :designation, presence: true
end
