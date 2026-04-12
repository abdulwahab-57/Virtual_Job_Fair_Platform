import { Controller } from "@hotwired/stimulus"

// Validates profile picture file type client-side before upload.
// Accepted types must match the server-side model validation so the
// user never sees a server error for something we could catch instantly.
export default class extends Controller {
  static targets = ["input", "error", "hint"]

  static ALLOWED_TYPES = ["image/jpeg", "image/png"]
  static ALLOWED_LABEL = "JPEG or PNG"

  validate(event) {
    const file = event.target.files[0]

    if (!file) {
      this.clearError()
      return
    }

    if (!this.constructor.ALLOWED_TYPES.includes(file.type)) {
      // Show the inline error and clear the bad file so it cannot be submitted
      this.showError(file.name, file.type)
      event.target.value = ""
    } else {
      this.clearError()
    }
  }

  showError(fileName, mimeType) {
    // Derive a readable label from the mime type (e.g. "application/pdf" → "PDF")
    const typeLabel = mimeType.split("/").pop().toUpperCase()
    this.errorTarget.textContent =
      `"${fileName}" is a ${typeLabel} file. ` +
      `Please upload a ${this.constructor.ALLOWED_LABEL} image instead.`
    this.errorTarget.classList.remove("hidden")
    this.hintTarget.classList.add("hidden")
  }

  clearError() {
    this.errorTarget.classList.add("hidden")
    this.hintTarget.classList.remove("hidden")
  }
}
