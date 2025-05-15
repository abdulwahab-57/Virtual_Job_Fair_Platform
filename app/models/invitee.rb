class Invitee < ApplicationRecord
  belongs_to :meeting
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
