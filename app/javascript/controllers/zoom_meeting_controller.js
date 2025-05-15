import { Controller } from "@hotwired/stimulus"


import "lodash";
import "react";
import "react-dom";
import "redux";
import "redux-thunk";
import "zoom-meeting-embedded";



export default class extends Controller {
  static targets = ["meetingSDKElement"]
  static values = {
    sdkKey: String,
    signature: String,
    meetingNumber: String,
    meetingPassword: String,
    userName: String
  }

  connect() {
    console.log("Zoom Meeting Controller connected")
    this.client = null
    this.initializeClient()
  }

  disconnect() {
    console.log("Zoom Meeting Controller disconnected")
    // Clean up when controller is disconnected
    if (this.client) {
      this.client.leave()
    }
  }


  initializeClient() {
    const meetingSDKElement = document.getElementById("meetingSDKElement")

    // Check if we have all required values
    if (!this.hasAllRequiredValues()) {
      this.showError("Missing required parameters for Zoom meeting")
      return
    }

    console.log("Initializing Zoom Meeting SDK with embedded client")
    console.log(`Meeting Number: ${this.meetingNumberValue}`)
    console.log(`User Name: ${this.userNameValue}`)

    try {
      // Create the Zoom Meeting Embedded client
      this.client = window.ZoomMtgEmbedded.createClient()

      // Initialize the client
      this.client.init({
        zoomAppRoot: meetingSDKElement,
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
    console.log(`Password: ${this.meetingPasswordValue}`)
    console.log(`User Name: ${this.userNameValue}`)
    console.log(`SDK Key: ${this.sdkKeyValue}`)
    console.log(`Signature: ${this.signatureValue}`)

    this.client.join({
      sdkKey: this.sdkKeyValue,
      signature: this.signatureValue,
      meetingNumber: this.meetingNumberValue,
      password: this.meetingPasswordValue,
      userName: this.userNameValue
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
      this.signatureValue &&
      this.meetingNumberValue &&
      this.meetingPasswordValue &&
      this.userNameValue
    )
  }

  showError(message) {
    const container = document.getElementById("meetingSDKElement")
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