class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      # Update the conversation's timestamp
      @conversation.touch

      # Redirect to inbox with conversation_id parameter
      redirect_to inbox_path(conversation_id: @conversation.id), notice: "Message sent"
    else
      # Handle validation errors
      redirect_to inbox_path(conversation_id: @conversation.id), alert: "Message could not be sent. #{@message.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
    # Check if the current user is part of this conversation
    unless @conversation.sender_id == current_user.id || @conversation.recipient_id == current_user.id
      redirect_to inbox_path, alert: "You don't have access to this conversation."
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
