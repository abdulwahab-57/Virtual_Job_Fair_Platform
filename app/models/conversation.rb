class Conversation < ApplicationRecord
  # Associations
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :messages, dependent: :destroy

  # Validations
  validates :sender_id, uniqueness: { scope: :recipient_id }

  # Scope to find conversations involving a specific user (either as sender or recipient)
  scope :involving, ->(user_id) do
    where("sender_id = ? OR recipient_id = ?", user_id, user_id)
  end

  # Scope to find a conversation between two specific users
  scope :between, ->(sender_id, recipient_id) do
    where("(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
          sender_id, recipient_id, recipient_id, sender_id)
  end

  # Scope to order conversations by most recent message
  scope :by_most_recent, -> { order(updated_at: :desc) }

  # Helper method to get the most recent message
  def most_recent_message
    messages.order(created_at: :desc).first
  end

  # Helper method to check if conversation has unread messages for a user
  def unread_messages_for?(user)
    messages.where(read: false).where.not(user_id: user.id).exists?
  end

  # Helper method to count unread messages for a user
  def unread_messages_count_for(user)
    messages.where(read: false).where.not(user_id: user.id).count
  end

  # Helper method to get the other participant in the conversation
  def other_participant(user)
    user.id == sender_id ? recipient : sender
  end

  # Find or create a conversation between two users
  def self.get_or_create(sender_id, recipient_id)
    conversation = between(sender_id, recipient_id).first

    # Create the conversation if it doesn't exist
    if conversation.nil?
      conversation = create(sender_id: sender_id, recipient_id: recipient_id)
    end

    conversation
  end
end
