import { Controller } from "@hotwired/stimulus"
import { getCurrentTime } from "../helpers/chat_helpers"

export default class extends Controller {
  static targets = ["button", "messages", "input"]
  static values = {
    userId: Number,
    roomId: String,
    otherUserId: Number
  }
  
  connect() {
    this.audioChunks = []
    this.isRecording = false
    this.mediaRecorder = null
  }

  startRecording() {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        this.mediaRecorder = new MediaRecorder(stream)
        this.mediaRecorder.ondataavailable = e => this.audioChunks.push(e.data)
        this.mediaRecorder.onstop = this._handleRecordingStop.bind(this)
        this.mediaRecorder.start()
        this.buttonTarget.textContent = "Recording..."
        this.isRecording = true
      })
      .catch(error => {
        console.error("Error accessing microphone:", error)
        this.buttonTarget.textContent = "🎙️ Mic Access Denied"
      })
  }

  stopRecording() {
    if (this.isRecording && this.mediaRecorder) {
      this.mediaRecorder.stop()
      this.buttonTarget.textContent = "🎙️ Hold to Record"
      this.isRecording = false
      
      // Stop all tracks
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop())
    }
  }

  _handleRecordingStop() {
    const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
    this.audioChunks = []
    
    const reader = new FileReader()
    reader.onload = (event) => {
      this.dispatch('sendVoice', {
        detail: {
          type: 'voice',
          content: event.target.result,
          sender_id: this.userIdValue,
          room_id: this.roomIdValue,
          receiver_id: this.otherUserIdValue
        }
      })
      
      this._showRecordingOptions(URL.createObjectURL(audioBlob))
    }
    reader.readAsDataURL(audioBlob)
  }

  _showRecordingOptions(audioUrl) {
    const options = document.createElement('div')
    options.className = 'recording-options'
    
    options.innerHTML = `
      <button class="send-btn" data-action="click->chat-voice#_sendRecording">Send</button>
      <button class="discard-btn" data-action="click->chat-voice#_discardRecording">Discard</button>
      <audio src="${audioUrl}" controls></audio>
    `
    
    this.messagesTarget.appendChild(options)
    this._currentAudioUrl = audioUrl
    this._scrollToBottom()
  }

  _sendRecording() {
    const audioBubble = this._createAudioBubble(this._currentAudioUrl)
    this.messagesTarget.appendChild(audioBubble)
    this._cleanupRecording()
    this._scrollToBottom()
  }

  _discardRecording() {
    this._cleanupRecording()
  }

  _createAudioBubble(audioUrl) {
    const bubble = document.createElement('div')
    bubble.className = 'message voice'
    
    const audio = document.createElement('audio')
    audio.controls = true
    audio.src = audioUrl
    
    const meta = document.createElement('div')
    meta.className = 'meta'
    meta.textContent = getCurrentTime()
    
    bubble.appendChild(audio)
    bubble.appendChild(meta)
    return bubble
  }

  _cleanupRecording() {
    document.querySelector('.recording-options')?.remove()
    this._currentAudioUrl = null
  }

  _scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}