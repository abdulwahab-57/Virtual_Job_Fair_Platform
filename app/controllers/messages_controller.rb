class MessagesController < ApplicationController
  before_action :authenticate_user! # Ensure user is logged in

  def index
    @messages = Message.where(sender_id: current_user.id)
                       .or(Message.where(receiver_id: current_user.id))
                       .order(:sent_at)

    render json: @messages
  end

  def create
    message = Message.new(message_params)
    message.sender_id = current_user.id
    message.sent_at = Time.current
    if message.save
      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:receiver_id, :message_type, :message_content)
  end
end
