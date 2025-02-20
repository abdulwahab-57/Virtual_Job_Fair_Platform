import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.messageTargets.forEach((el, index) => {
      setTimeout(() => {
        el.classList.remove("translate-x-20", "opacity-0");
      }, 100 * index); // Staggered animation

      setTimeout(() => {
        this.fadeOut(el);
      }, 5000); // Message disappears after 5 seconds
    });
  }

  close(event) {
    const el = event.currentTarget.closest("[data-flash-target='message']");
    this.fadeOut(el);
  }

  fadeOut(el) {
    el.classList.add("opacity-0", "translate-x-20");
    setTimeout(() => el.remove(), 500); // Remove from DOM after animation
  }
}
