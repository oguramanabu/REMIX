import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shippingAddressSelect"]
  static values = { shippingAddressesUrl: String }

  updateShippingAddresses(event) {
    const clientId = event.target.value
    if (!clientId) {
      this.clearShippingAddresses()
      return
    }

    fetch(`${this.shippingAddressesUrlValue}?client_id=${clientId}`)
      .then(response => response.json())
      .then(data => {
        this.populateShippingAddresses(data)
      })
      .catch(error => {
        console.error("Error fetching shipping addresses:", error)
        this.clearShippingAddresses()
      })
  }

  clearShippingAddresses() {
    this.shippingAddressSelectTarget.innerHTML = '<option value="">選択してください</option>'
  }

  populateShippingAddresses(addresses) {
    this.clearShippingAddresses()
    
    addresses.forEach(address => {
      const option = document.createElement('option')
      option.value = address.id
      option.textContent = address.display_name
      this.shippingAddressSelectTarget.appendChild(option)
    })
  }
}