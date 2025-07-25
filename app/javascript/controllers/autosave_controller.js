import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  static values = { 
    url: String,
    method: String,
    interval: { type: Number, default: 3000 }
  }

  connect() {
    this.timeout = null
    this.saving = false
    this.lastSavedData = null
    
    // Start listening for changes
    this.startListening()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  startListening() {
    // Listen to all form inputs
    this.formTarget.addEventListener("input", this.handleChange.bind(this))
    this.formTarget.addEventListener("change", this.handleChange.bind(this))
    
    // Listen to file drops and other interactions
    this.formTarget.addEventListener("drop", this.handleChange.bind(this))
    
    // Listen for URL management buttons
    document.addEventListener("click", (e) => {
      if (e.target.id === "add-url" || e.target.classList.contains("remove-url")) {
        this.handleChange()
      }
    })
  }

  handleChange() {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Set new timeout
    this.timeout = setTimeout(() => {
      this.autosave()
    }, this.intervalValue)
  }

  async autosave() {
    if (this.saving) return

    const formData = new FormData(this.formTarget)
    
    // Remove file inputs from autosave to prevent duplication
    formData.delete("order[files][]")
    
    // Add draft status for auto-save
    formData.set("order[status]", "draft")
    formData.set("commit", "autosave")
    
    // Check if data has changed
    const currentData = this.serializeFormData(formData)
    if (currentData === this.lastSavedData) {
      return
    }

    this.saving = true

    try {
      const response = await fetch(this.urlValue, {
        method: this.methodValue,
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Accept": "application/json"
        }
      })

      if (response.ok) {
        const data = await response.json()
        
        // Update form action and method if this was a new record
        if (data.redirect_url) {
          this.formTarget.action = data.redirect_url
          this.formTarget.querySelector("input[name='_method']")?.remove()
          const methodInput = document.createElement("input")
          methodInput.type = "hidden"
          methodInput.name = "_method"
          methodInput.value = "patch"
          this.formTarget.appendChild(methodInput)
          
          // Update controller values for future saves
          this.urlValue = data.redirect_url
          this.methodValue = "PATCH"
          
          // Update browser URL without reload
          window.history.replaceState({}, "", data.edit_url)
        }

        this.lastSavedData = currentData
        this.showSuccessToast()
      }
    } catch (error) {
      console.error("Autosave failed:", error)
    } finally {
      this.saving = false
    }
  }

  serializeFormData(formData) {
    const entries = []
    for (let [key, value] of formData.entries()) {
      if (key !== "authenticity_token" && key !== "commit" && key !== "order[files][]") {
        entries.push(`${key}=${value}`)
      }
    }
    return entries.sort().join("&")
  }

  showSuccessToast() {
    // Check if toast already exists
    const existingToast = document.querySelector(".autosave-toast")
    if (existingToast) {
      existingToast.remove()
    }

    const toast = document.createElement("div")
    toast.className = "autosave-toast alert alert-success fixed top-4 right-4 w-auto z-50 shadow-lg"
    toast.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>下書きが自動保存されました</span>
    `
    
    document.body.appendChild(toast)
    
    setTimeout(() => {
      toast.style.opacity = "0"
      toast.style.transition = "opacity 0.3s"
      setTimeout(() => {
        toast.remove()
      }, 300)
    }, 3000)
  }
}