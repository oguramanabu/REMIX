import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "warning"]

  validateAndSubmit(event) {
    const fileInput = this.fileInputTarget
    const warning = this.warningTarget
    
    // Check if a file is selected
    if (!fileInput.files || fileInput.files.length === 0) {
      event.preventDefault()
      warning.classList.remove("hidden")
      
      // Hide warning after 3 seconds
      setTimeout(() => {
        warning.classList.add("hidden")
      }, 3000)
      
      return false
    }
    
    // Check if selected file is JPG or PNG
    const file = fileInput.files[0]
    const allowedTypes = ['image/jpeg', 'image/png']
    
    if (!allowedTypes.includes(file.type)) {
      event.preventDefault()
      warning.classList.remove("hidden")
      
      // Hide warning after 3 seconds
      setTimeout(() => {
        warning.classList.add("hidden")
      }, 3000)
      
      return false
    }
    
    // Hide warning if validation passes
    warning.classList.add("hidden")
    
    // Allow form submission
    return true
  }
}