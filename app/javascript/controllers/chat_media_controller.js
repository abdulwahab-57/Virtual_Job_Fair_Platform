import { Controller } from "@hotwired/stimulus"
import { createMediaPreview } from "../helpers/chat_helpers"

export default class extends Controller {
  static targets = ["messages", "input"]
  static values = {
    userId: Number,
    roomId: String,
    otherUserId: Number
  }

  openGallery() {
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = 'image/*, video/*, .pdf, .doc, .docx, .txt'
    input.multiple = true
    input.onchange = (e) => this.handleFiles(e.target.files)
    input.click()
  }

  handleFiles(files) {
    Array.from(files).forEach(file => {
      const reader = new FileReader()
      reader.onload = (event) => {
        this.dispatch('sendMedia', {
          detail: {
            type: this._getMessageType(file.type),
            file_type: file.type,
            file_name: file.name,
            content: event.target.result,
            sender_id: this.userIdValue,
            room_id: this.roomIdValue,
            receiver_id: this.otherUserIdValue
          }
        })
        this._displayMediaMessage(file, event.target.result)
      }
      
      if (file.type.startsWith('image/') || file.type.startsWith('video/')) {
        reader.readAsDataURL(file)
      } else {
        reader.readAsText(file)
      }
    })
  }

  _displayMediaMessage(file, content) {
    const messageElement = document.createElement('div')
    messageElement.className = 'message media'
    
    const contentElement = document.createElement('div')
    contentElement.className = 'content'
    contentElement.appendChild(createMediaPreview(file, content))

    const metaElement = document.createElement('div')
    metaElement.className = 'meta'
    metaElement.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })

    messageElement.appendChild(contentElement)
    messageElement.appendChild(metaElement)
    this.messagesTarget.appendChild(messageElement)
    this._scrollToBottom()
  }

  _getMessageType(fileType) {
    if (fileType.startsWith('image/')) return 'image'
    if (fileType.startsWith('video/')) return 'video'
    if (fileType.startsWith('audio/')) return 'audio'
    return 'document'
  }

  _scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}