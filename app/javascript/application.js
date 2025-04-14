import { Application } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

const application = Application.start()

// Configure Stimulus
application.debug = process.env.NODE_ENV === "development"
window.Stimulus = application
window.ChatConsumer = consumer

// Export for potential module usage
export { application }