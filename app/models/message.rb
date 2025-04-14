class Message < ApplicationRecord
  # Associations
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  # Enums
  enum status: { unread: 0, read: 1 }
  enum message_type: { text: 0, image: 1, file: 2 }

  # Validations
  validates :sender_id, :receiver_id, :message_content, :message_type, :sent_at, presence: true
  validates :message_content, length: { maximum: 1000 }

  # Custom validation for attachments and emojis
  validate :validate_media

  private

  def validate_media
    if message_type == "image" || message_type == "file"
      errors.add(:message_content, "must be a valid URL") unless message_content.match?(URI::regexp)
    end

    if message_type == "text"
      # Basic emoji validation (checks for Unicode emoji ranges)
      if message_content.match?(/\p{Emoji}/)
        errors.add(:message_content, "contains unsupported emojis")
      end
    end
  end
end
