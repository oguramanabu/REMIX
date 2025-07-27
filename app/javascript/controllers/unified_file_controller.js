import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropZone", "selectedContainer", "selectedList"]
  
  connect() {
    this.currentFiles = []
    this.reset()
  }
  
  disconnect() {
  }
  
  reset() {
    // Clear any existing file selection
    if (this.hasInputTarget) {
      this.inputTarget.value = ''
    }
    
    // Hide selected files container
    if (this.hasSelectedContainerTarget) {
      this.selectedContainerTarget.classList.add('hidden')
    }
    
    // Clear selected files list
    if (this.hasSelectedListTarget) {
      this.selectedListTarget.innerHTML = ''
    }
    
    this.currentFiles = []
  }
  
  // Handle drop zone click
  click(event) {
    if (this.hasInputTarget) {
      this.inputTarget.click()
    }
  }
  
  // Handle file input change
  change(event) {
    if (event.target.files.length > 0) {
      this.currentFiles = Array.from(event.target.files)
      this.displaySelectedFiles()
    } else {
      this.reset()
    }
  }
  
  // Drag and drop handlers
  dragenter(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add('border-blue-400', 'bg-blue-50')
  }
  
  dragover(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add('border-blue-400', 'bg-blue-50')
  }
  
  dragleave(event) {
    event.preventDefault()
    if (!this.dropZoneTarget.contains(event.relatedTarget)) {
      this.dropZoneTarget.classList.remove('border-blue-400', 'bg-blue-50')
    }
  }
  
  drop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove('border-blue-400', 'bg-blue-50')
    
    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.inputTarget.files = files
      this.currentFiles = Array.from(files)
      this.displaySelectedFiles()
    }
  }
  
  displaySelectedFiles() {
    if (!this.hasSelectedContainerTarget || !this.hasSelectedListTarget) {
      return
    }
    
    // Clear previous selection display
    this.selectedListTarget.innerHTML = ''
    
    if (this.currentFiles.length === 0) {
      this.selectedContainerTarget.classList.add('hidden')
      return
    }
    
    // Show the container
    this.selectedContainerTarget.classList.remove('hidden')
    
    // Display each file
    this.currentFiles.forEach((file, index) => {
      const fileItem = document.createElement('div')
      fileItem.className = 'flex items-center justify-between p-2 bg-gray-50 rounded-lg'
      fileItem.dataset.fileIndex = index
      
      fileItem.innerHTML = `
        <div class="flex items-center">
          <svg class="w-4 h-4 text-gray-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
          </svg>
          <span class="text-sm text-gray-700">${file.name}</span>
        </div>
        <div class="flex items-center space-x-2">
          <span class="text-xs text-gray-500">${this.formatFileSize(file.size)}</span>
          <button type="button" class="text-xs text-red-600 hover:text-red-700" data-action="click->unified-file#removeNewFile" data-file-index="${index}">削除</button>
        </div>
      `
      
      this.selectedListTarget.appendChild(fileItem)
    })
  }
  
  // Remove a newly selected file
  removeNewFile(event) {
    const fileIndex = parseInt(event.currentTarget.dataset.fileIndex)
    this.currentFiles.splice(fileIndex, 1)
    
    // Update the file input with remaining files
    const dt = new DataTransfer()
    this.currentFiles.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files
    
    // Redisplay the files
    this.displaySelectedFiles()
  }
  
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}