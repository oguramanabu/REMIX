import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "label" ]

  connect() {
    this.updateLabelColor()
  }

  toggle() {
    this.updateLabelColor()
  }

  updateLabelColor() {
    const isChecked = this.element.querySelector('input[type="checkbox"]').checked
    
    if (isChecked) {
      this.labelTarget.classList.remove('text-gray-500')
      this.labelTarget.classList.add('text-gray-700')
    } else {
      this.labelTarget.classList.remove('text-gray-700')
      this.labelTarget.classList.add('text-gray-500')
    }
  }
}