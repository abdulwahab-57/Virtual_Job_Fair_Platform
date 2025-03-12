import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["meetingContainer"]
  static values = {
    sdkKey: String,
    meetingNumber: String,
    password: String,
    signature: String,
    userName: String,
    userEmail: String,
    role: Number
  }

  connect() {
    console.log("Zoom Meeting Controller connected")
    this.client = null
    this.loadZoomSdk()
  }

  disconnect() {
    console.log("Zoom Meeting Controller disconnected")
    // Clean up when controller is disconnected
    if (this.client) {
      this.client.leave()
    }
  }

  loadZoomSdk() {
    // Load the Zoom Meeting SDK by creating a script element
    // This is more reliable than using import() since we need to access the global ZoomMtgEmbed object
    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = '/node_modules/@zoom/meetingsdk/dist/zoomus-websdk-embedded.umd.min.js'
      script.async = true
      script.onload = () => {
        console.log('Zoom Meeting SDK loaded')
        if (window.ZoomMtgEmbed) {
          this.ZoomMtgEmbedded = window.ZoomMtgEmbed
          this.initializeClient()
          resolve()
        } else {
          const error = new Error('ZoomMtgEmbed not found in window object')
          console.error(error)
          this.showError('Failed to load Zoom Meeting SDK: ZoomMtgEmbed not found')
          reject(error)
        }
      }
      script.onerror = (error) => {
        console.error('Failed to load Zoom Meeting SDK', error)
        this.showError('Failed to load Zoom Meeting SDK')
        reject(error)
      }
      document.head.appendChild(script)
    })
  }

  initializeClient() {
    const meetingContainer = this.meetingContainerTarget

    // Check if we have all required values
    if (!this.hasAllRequiredValues()) {
      this.showError("Missing required parameters for Zoom meeting")
      return
    }

    console.log("Initializing Zoom Meeting SDK with embedded client")
    console.log(`Meeting Number: ${this.meetingNumberValue}`)
    console.log(`User Name: ${this.userNameValue}`)
    console.log(`Role: ${this.roleValue}`)

    try {
      // Create the Zoom Meeting Embedded client
      this.client = this.ZoomMtgEmbedded.createClient()

      // Initialize the client
      this.client.init({
        zoomAppRoot: meetingContainer,
        language: 'en-US',
        patchJsMedia: true
      }).then(() => {
        // Join the meeting after initialization
        this.joinMeeting()
      }).catch((error) => {
        console.error('Failed to initialize Zoom Meeting SDK', error)
        this.showError(`Failed to initialize Zoom Meeting: ${error.message || 'Unknown error'}`)
      })
    } catch (error) {
      console.error('Failed to create Zoom Meeting client', error)
      this.showError(`Failed to create Zoom Meeting client: ${error.message || 'Unknown error'}`)
    }
  }

  joinMeeting() {
    console.log('Joining Zoom meeting...')
    console.log(`Meeting Number: ${this.meetingNumberValue}`)
    console.log(`Password: ${this.passwordValue}`)
    console.log(`User Name: ${this.userNameValue}`)
    console.log(`User Email: ${this.userEmailValue}`)
    console.log(`Role: ${this.roleValue}`)

    this.client.join({
      sdkKey: this.sdkKeyValue,
      signature: this.signatureValue,
      meetingNumber: this.meetingNumberValue,
      password: this.passwordValue,
      userName: this.userNameValue,
      userEmail: this.userEmailValue
    }).then(() => {
      console.log('Joined Zoom meeting successfully')
    }).catch((error) => {
      console.error('Failed to join Zoom meeting', error)
      this.showError(`Failed to join meeting: ${error.message || 'Unknown error'}`)
    })
  }

  hasAllRequiredValues() {
    return (
      this.sdkKeyValue &&
      this.meetingNumberValue &&
      this.passwordValue &&
      this.signatureValue &&
      this.userNameValue
    )
  }

  showError(message) {
    const container = this.meetingContainerTarget
    container.innerHTML = `
      <div class="flex flex-col items-center justify-center h-full p-8 text-center">
        <svg class="w-16 h-16 text-red-500 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <h3 class="text-lg font-medium text-gray-900 mb-2">Failed to join the meeting</h3>
        <p class="text-gray-600 mb-4">${message}</p>
      </div>
    `
  }
} 