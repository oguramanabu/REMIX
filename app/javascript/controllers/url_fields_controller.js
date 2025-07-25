import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  addUrl() {
    const newUrlField = document.createElement('div')
    newUrlField.classList.add('url-field', 'flex', 'gap-2', 'mb-2')
    newUrlField.innerHTML = `
      <input type="text" name="order[attachment_urls][]" class="input input-bordered flex-1" placeholder="https://example.com/document">
      <button type="button" class="btn btn-warning btn-sm" data-action="click->url-fields#removeUrl">削除</button>
    `
    this.containerTarget.appendChild(newUrlField)
  }

  removeUrl(event) {
    const urlField = event.target.closest('.url-field')
    
    // 最後のフィールドの場合は値をクリアするだけ
    if (this.containerTarget.children.length > 1) {
      urlField.remove()
    } else {
      urlField.querySelector('input').value = ''
    }
  }
}