import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropZone", "selectedContainer", "selectedList", "existingContainer"]
  static values = { orderId: String }
  
  connect() {
    console.log("Unified file controller connected", { orderId: this.orderIdValue })
    this.currentFiles = []
    this.reset()
  }
  
  disconnect() {
    console.log("Unified file controller disconnected")
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
    console.log('Drop zone clicked')
    if (this.hasInputTarget) {
      this.inputTarget.click()
    }
  }
  
  // Handle file input change
  change(event) {
    console.log('File input changed with files:', event.target.files.length)
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
  
  // Remove an existing saved file
  async removeExistingFile(event) {
    event.preventDefault()
    
    const fileId = event.currentTarget.dataset.fileId
    const orderId = this.orderIdValue
    
    console.log('Delete existing file attempt:', { fileId, orderId })
    
    if (!fileId || !orderId) {
      console.error('Missing file ID or order ID', { fileId, orderId })
      this.showMessage('ファイルIDまたはオーダーIDが見つかりません', 'error')
      return
    }

    if (!confirm('このファイルを削除しますか？')) {
      return
    }

    try {
      console.log('Making DELETE request to:', `/orders/${orderId}/attachments/${fileId}`)
      
      const response = await fetch(`/orders/${orderId}/attachments/${fileId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })

      console.log('Response status:', response.status)

      if (!response.ok) {
        const errorText = await response.text()
        console.error('HTTP error response:', errorText)
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      console.log('Response data:', data)

      if (data.success) {
        // Remove the file item from the DOM
        const fileItem = event.currentTarget.closest('div.flex.items-center.justify-between')
        
        console.log('Found file item to remove:', fileItem)
        
        if (fileItem) {
          fileItem.remove()
          console.log('Successfully removed file item from DOM')
          
          // Show success message
          this.showMessage(data.message || 'ファイルが削除されました', 'success')

          // Check if there are no more files and hide the section
          if (this.hasExistingContainerTarget) {
            const remainingFiles = this.existingContainerTarget.querySelectorAll('div.flex.items-center.justify-between')
            console.log('Remaining files count:', remainingFiles.length)
            if (remainingFiles.length === 0) {
              this.existingContainerTarget.style.display = 'none'
              console.log('All existing files deleted, hiding container')
            }
          }
        } else {
          console.error('Could not find file item to remove')
          this.showMessage('DOMからファイル要素を見つけられませんでした', 'error')
        }
      } else {
        console.error('Server returned success=false:', data)
        this.showMessage(data.error || 'ファイルの削除に失敗しました', 'error')
      }
    } catch (error) {
      console.error('File deletion error:', error)
      this.showMessage('ファイルの削除中にエラーが発生しました: ' + error.message, 'error')
    }
  }

  showMessage(message, type) {
    // Create a temporary message element
    const messageDiv = document.createElement('div')
    messageDiv.className = `alert ${type === 'success' ? 'alert-success' : 'alert-error'} fixed top-4 right-4 z-50 max-w-sm`
    
    const icon = type === 'success' ? '✅' : '❌'
    messageDiv.innerHTML = `
      <div class="flex items-center space-x-2">
        <span class="text-lg">${icon}</span>
        <span>${message}</span>
      </div>
    `

    document.body.appendChild(messageDiv)
    
    console.log(`Showing ${type} message:`, message)

    // Remove after 4 seconds with fade out
    setTimeout(() => {
      if (messageDiv.parentNode) {
        messageDiv.style.opacity = '0'
        messageDiv.style.transition = 'opacity 0.3s ease-out'
        setTimeout(() => {
          if (messageDiv.parentNode) {
            messageDiv.parentNode.removeChild(messageDiv)
          }
        }, 300)
      }
    }, 4000)
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}