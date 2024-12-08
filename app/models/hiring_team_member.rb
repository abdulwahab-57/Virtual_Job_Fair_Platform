class HiringTeamMember < ApplicationRecord
  # Associations
  belongs_to :recruiter_profile

  # Validations
  validates :recruiter_profile_id, presence: true
  validates :name, presence: true
  validates :designation, presence: true
end
