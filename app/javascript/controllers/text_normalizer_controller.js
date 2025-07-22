import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="text-normalizer"
export default class extends Controller {
  connect() {
    console.log('Text normalizer controller connected!')
  }

  normalize(event) {
    console.log('Normalize action triggered')
    const input = event.target
    const cursorPosition = input.selectionStart
    const originalValue = input.value
    const normalizedValue = this.toHalfWidth(originalValue)
    
    console.log('Values:', { originalValue, normalizedValue })
    
    if (originalValue !== normalizedValue) {
      input.value = normalizedValue
      // Restore cursor position
      if (cursorPosition !== null) {
        input.setSelectionRange(cursorPosition, cursorPosition)
      }
    }
  }

  toHalfWidth(str) {
    return str
      // Convert full-width alphanumeric to half-width
      .replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
        return String.fromCharCode(s.charCodeAt(0) - 0xFEE0)
      })
      // Convert various dash types to regular hyphen
      .replace(/[－−‐]/g, '-')
      // Convert full-width space to half-width space
      .replace(/　/g, ' ')
  }
}