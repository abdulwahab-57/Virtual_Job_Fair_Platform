import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  applyFilters() {
    this.closeFilterDropdowns()
    this.formTarget.submit()
  }

  handleOutsideClick(event) {
    if (!event.target.closest("details")) {
      this.closeFilterDropdowns()
    }
  }

  closeFilterDropdowns() {
    this.element.querySelectorAll("details").forEach(d => d.removeAttribute("open"))
  }
}
