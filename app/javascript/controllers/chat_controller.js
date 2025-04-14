import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["input", "messages", "typingIndicator", "container", "header"]
  static values = {
    userId: Number,
    currentRoom: String,
    otherUserId: Number,
    otherUserName: String
  }

  connect() {
    this.chatHistory = {}
    this.isTyping = false
    this.typingTimeout = null
    this.subscription = consumer.subscriptions.create(
      { channel: "ChatChannel", user_id: this.userIdValue },
      { received: data => this.handleReceivedData(data) }
    )
    this.initializeEventListeners()
  }

  initializeEventListeners() {
    document.addEventListener('chat:open', (event) => {
      this.openChat(event.detail.userId, event.detail.userName)
    })
  }

  openChat(userId, userName) {
    this.otherUserIdValue = userId
    this.otherUserNameValue = userName
    this.currentRoomValue = this._generateRoomId(userId)
    this.headerTarget.textContent = `Chat with ${userName}`
    this.containerTarget.style.display = 'block'
    this._loadMessages()
  }

  sendMessage(event) {
    event.preventDefault()
    const content = this.inputTarget.value.trim()
    if (!content) return

    const messageData = {
      action: "send_message",
      sender_id: this.userIdValue,
      receiver_id: this.otherUserIdValue,
      message_type: "text",
      content: content,
      room_id: this.currentRoomValue
    }

    this.subscription.send(messageData)
    this._saveToHistory(content, 'sent')
    this.inputTarget.value = ""
    this.stopTyping()
  }

  handleReceivedData(data) {
    switch(data.action) {
      case "new_message":
        this.appendMessage(data.message)
        this._saveToHistory(data.message.content, 'received')
        break
      case "typing":
        this.handleTypingIndicator(data)
        break
      case "notification":
        this.handleNotification(data)
        break
      case "read_receipt":
        this.updateReadStatus(data)
        break
    }
  }

  appendMessage(message) {
    const messageClass = message.sender_id === this.userIdValue ? "sent" : "received"
    const messageElement = this._createMessageElement(message, messageClass)
    this.messagesTarget.appendChild(messageElement)
    this.scrollToBottom()
  }

  _createMessageElement(message, messageClass) {
    const element = document.createElement('div')
    element.className = `message ${messageClass}`
    element.dataset.messageId = message.id
    element.innerHTML = `
      <div class="content">${message.content}</div>
      <div class="meta">
        ${this.formatTime(message.sent_at)}
        ${message.status === "read" ? '✓✓' : '✓'}
      </div>
    `
    return element
  }

  _saveToHistory(content, type) {
    if (!this.chatHistory[this.currentRoomValue]) {
      this.chatHistory[this.currentRoomValue] = []
    }
    
    this.chatHistory[this.currentRoomValue].push({
      content: content,
      type: type,
      timestamp: new Date().toISOString()
    })
    
    localStorage.setItem(`chatHistory_${this.currentRoomValue}`, 
      JSON.stringify(this.chatHistory[this.currentRoomValue]))
  }

  _loadMessages() {
    this.messagesTarget.innerHTML = ''
    
    const savedHistory = localStorage.getItem(`chatHistory_${this.currentRoomValue}`)
    if (savedHistory) {
      this.chatHistory[this.currentRoomValue] = JSON.parse(savedHistory)
      this.chatHistory[this.currentRoomValue].forEach(msg => {
        const messageElement = this._createMessageElement({
          id: Date.now(),
          content: msg.content,
          sender_id: msg.type === 'sent' ? this.userIdValue : this.otherUserIdValue,
          sent_at: msg.timestamp,
          status: 'read'
        }, msg.type)
        this.messagesTarget.appendChild(messageElement)
      })
    }
    
    fetch(`/messages?room_id=${this.currentRoomValue}`)
      .then(response => response.json())
      .then(messages => {
        messages.forEach(message => {
          if (!this._messageExists(message.id)) {
            this.appendMessage(message)
            this._saveToHistory(message.content, 
              message.sender_id === this.userIdValue ? 'sent' : 'received')
          }
        })
        this.scrollToBottom()
      })
  }

  _messageExists(messageId) {
    return !!this.messagesTarget.querySelector(`[data-message-id="${messageId}"]`)
  }

  _generateRoomId(userId) {
    const ids = [this.userIdValue, userId].sort()
    return `chat_${ids.join('_')}`
  }

  onInput() {
    this.startTyping()
    clearTimeout(this.typingTimeout)
    this.typingTimeout = setTimeout(() => this.stopTyping(), 2000)
  }

  startTyping() {
    if (!this.isTyping) {
      this.isTyping = true
      this.subscription.send({
        action: "typing",
        sender_id: this.userIdValue,
        receiver_id: this.otherUserIdValue,
        is_typing: true
      })
    }
  }

  stopTyping() {
    if (this.isTyping) {
      this.isTyping = false
      this.subscription.send({
        action: "typing",
        sender_id: this.userIdValue,
        receiver_id: this.otherUserIdValue,
        is_typing: false
      })
    }
  }

  handleTypingIndicator(data) {
    if (data.is_typing) {
      this.typingIndicatorTarget.textContent = `${this.otherUserNameValue} is typing...`
      this.typingIndicatorTarget.style.display = "block"
    } else {
      this.typingIndicatorTarget.style.display = "none"
    }
  }

  handleNotification(data) {
    if (!document.hasFocus() && Notification.permission === "granted") {
      new Notification(`New message from ${this.otherUserNameValue}`, {
        body: data.message.content,
        icon: '/icon.png'
      })
    }
  }

  updateReadStatus(data) {
    this.messagesTarget.querySelectorAll('.message.sent').forEach(message => {
      const meta = message.querySelector('.meta')
      if (meta) {
        meta.innerHTML = meta.innerHTML.replace('✓', '✓✓')
      }
    })
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  formatTime(timestamp) {
    const date = new Date(timestamp)
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    clearTimeout(this.typingTimeout)
  }
}