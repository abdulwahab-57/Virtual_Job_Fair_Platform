class Message < ApplicationRecord
  # Associations
  belongs_to :conversation, touch: true
  belongs_to :user

  # Validations
  validates :body, presence: true
  validates :conversation_id, presence: true
  validates :user_id, presence: true

  # Callbacks
  after_create :touch_conversation

  # Scope to get recent messages
  scope :recent, -> { order(created_at: :desc) }

  # Mark message as read
  def mark_as_read!
    update(read: true) unless read?
  end

  private

  # Update the conversation's updated_at timestamp
  def touch_conversation
    conversation.touch
  end
end
