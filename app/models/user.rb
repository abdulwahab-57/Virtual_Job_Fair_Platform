class User < ApplicationRecord
  # Associations
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id", dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: "receiver_id", dependent: :destroy
  has_many :searches, class_name: "SearchUser", dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_digest, presence: true, length: { minimum: 6 }

  # Enum validation (assuming you have defined enum in the model)
  enum role: { student: 0, recruiter: 1, career_office: 2 }
end
