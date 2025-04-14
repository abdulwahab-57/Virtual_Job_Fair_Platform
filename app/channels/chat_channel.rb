class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:user_id]}"
    stream_from "chat_notifications_#{params[:user_id]}"
  end

  def unsubscribed
    # Cleanup any resources
  end

  def receive(data)
    case data["action"]
    when "send_message"
      create_and_broadcast_message(data)
    when "typing"
      broadcast_typing_status(data)
    when "read_receipt"
      update_read_status(data)
    end
  end

  private

  def create_and_broadcast_message(data)
    message = Message.create!(
      sender_id: data["sender_id"],
      receiver_id: data["receiver_id"],
      message_type: data["message_type"],
      content: data["content"],
      room_id: data["room_id"],
      status: :unread
    )

    broadcast_to_recipient(message)
    send_notification(message)
  end

  def broadcast_to_recipient(message)
    ActionCable.server.broadcast(
      "chat_#{message.receiver_id}",
      action: "new_message",
      message: message_data(message)
  end

  def send_notification(message)
    ActionCable.server.broadcast(
      "chat_notifications_#{message.receiver_id}",
      action: "notification",
      message: message_data(message))
  end

  def broadcast_typing_status(data)
    ActionCable.server.broadcast(
      "chat_#{data["receiver_id"]}",
      action: "typing",
      sender_id: data["sender_id"],
      is_typing: data["is_typing"]
    )
  end

  def update_read_status(data)
    Message.where(room_id: data["room_id"], receiver_id: data["sender_id"])
           .update_all(status: :read)
  end

  def message_data(message)
    {
      id: message.id,
      content: message.content,
      sender_id: message.sender_id,
      receiver_id: message.receiver_id,
      message_type: message.message_type,
      room_id: message.room_id,
      sent_at: message.created_at,
      status: message.status
    }
  end
end