class Meeting < ApplicationRecord
  belongs_to :user
  has_many :invitees, dependent: :destroy

  validates :meeting_number, presence: true, uniqueness: true

  attr_accessor :invitees_list
end
