import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tag-suggestions"
export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.debounceTimer = null
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener('click', this.boundClickOutside)
  }

  search(event) {
    const query = event.target.value.trim()
    
    clearTimeout(this.debounceTimer)
    
    if (query.length === 0) {
      this.hideSuggestions()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 300)
  }

  async fetchSuggestions(query) {
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
      const response = await fetch(`/items/search?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
        }
      })
      
      if (response.ok) {
        const items = await response.json()
        this.displaySuggestions(items)
      } else {
        console.error('Failed to fetch suggestions:', response.statusText)
      }
    } catch (error) {
      console.error('Error fetching suggestions:', error)
    }
  }

  displaySuggestions(items) {
    if (items.length === 0) {
      this.hideSuggestions()
      return
    }

    const suggestionsHTML = items.map(item => 
      `<div class="suggestion-item p-2 cursor-pointer hover:bg-base-200" 
           data-action="click->tag-suggestions#selectSuggestion" 
           data-name="${item.name}" 
           data-description="${item.description}">
         <div class="font-semibold">${item.name}</div>
         <div class="text-sm text-gray-600">${item.description}</div>
       </div>`
    ).join('')

    this.suggestionsTarget.innerHTML = suggestionsHTML
    this.suggestionsTarget.classList.remove('hidden')
  }

  selectSuggestion(event) {
    const name = event.currentTarget.dataset.name
    this.inputTarget.value = name
    this.hideSuggestions()
    
    const changeEvent = new Event('change', { bubbles: true })
    this.inputTarget.dispatchEvent(changeEvent)
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add('hidden')
    this.suggestionsTarget.innerHTML = ''
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
    document.removeEventListener('click', this.boundClickOutside)
  }
}
