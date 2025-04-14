import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "main", "emojiButton", "videoButton", "audioButton", "messages", "header"]

  toggleSidebar() {
    this.sidebarTarget.classList.toggle('collapsed')
    this.mainTarget.classList.toggle('expanded')
  }

  showChatInterface(userName) {
    this.headerTarget.textContent = `Chat with ${userName}`
    this.emojiButtonTarget.style.display = 'inline-block'
    this.videoButtonTarget.style.display = 'inline-block'
    this.audioButtonTarget.style.display = 'inline-block'
    this.messagesTarget.style.overflowY = 'auto'
  }

  showDefaultMessage() {
    this.headerTarget.textContent = "Select a user"
    this.messagesTarget.innerHTML = '<div class="default-message"><p>Select a user to start chatting</p></div>'
    this.emojiButtonTarget.style.display = 'none'
    this.videoButtonTarget.style.display = 'none'
    this.audioButtonTarget.style.display = 'none'
    this.messagesTarget.style.overflowY = 'hidden'
  }

  toggleFullscreen() {
    if (!document.fullscreenElement) {
      this.element.requestFullscreen().catch(err => {
        console.error(`Error attempting to enable fullscreen: ${err.message}`)
      })
    } else {
      document.exitFullscreen()
    }
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}