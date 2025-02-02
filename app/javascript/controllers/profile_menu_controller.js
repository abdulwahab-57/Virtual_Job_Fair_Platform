import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-menu"
export default class extends Controller {
  connect() {
    this.profileButton = document.getElementById("profile-button");
    this.profileMenu = document.getElementById("profile-menu");

    // Store the bound function in a property for later removal
    this.handleOutsideClick = this.closeOnClickOutside.bind(this);

    // Attach a global event listener to close the dropdown when clicking outside
    window.addEventListener("click", this.handleOutsideClick);
  }

  toggle(event) {
    event.stopPropagation(); // Prevent the click from propagating to the window
    this.profileMenu.classList.toggle("hidden");
  }

  closeOnClickOutside(event) {
    if (
      !this.profileButton.contains(event.target) &&
      !this.profileMenu.contains(event.target)
    ) {
      this.profileMenu.classList.add("hidden");
    }
  }

  disconnect() {
    window.removeEventListener("click", this.handleOutsideClick);
  }
}
