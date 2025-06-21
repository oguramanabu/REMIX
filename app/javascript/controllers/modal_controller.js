import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "backdrop"]

  connect() {
    // Add event listener for escape key
    this.handleEscape = this.handleEscape.bind(this)
    // Add event listener for custom close event
    this.element.addEventListener('modal:close', () => this.close())
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    document.addEventListener('keydown', this.handleEscape)
    document.body.style.overflow = 'hidden'
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    document.removeEventListener('keydown', this.handleEscape)
    document.body.style.overflow = ''
  }

  closeBackground(event) {
    if (event.target === this.modalTarget || event.target === this.backdropTarget) {
      this.close(event)
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscape)
    document.body.style.overflow = ''
  }
}