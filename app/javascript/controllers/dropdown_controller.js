import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    const isOpen = !this.menuTarget.classList.contains("hidden")

    // Close any other open dropdown menus on the page
    document.querySelectorAll("[data-dropdown-target='menu']").forEach(menu => {
      menu.classList.add("hidden")
    })

    if (!isOpen) {
      this.menuTarget.classList.remove("hidden")
      this._onOutsideClick = (e) => {
        if (!this.element.contains(e.target)) this.close()
      }
      this._onEscape = (e) => {
        if (e.key === "Escape") this.close()
      }
      document.addEventListener("click", this._onOutsideClick)
      document.addEventListener("keydown", this._onEscape)
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this._onOutsideClick)
    document.removeEventListener("keydown", this._onEscape)
  }

  disconnect() {
    this.close()
  }
}
