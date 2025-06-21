import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Animate in
    setTimeout(() => {
      this.element.classList.remove('translate-x-full')
    }, 100)
    
    // Auto hide after 5 seconds
    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    this.element.classList.add('translate-x-full')
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}