import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileItem"]
  static values = { orderId: String }
  
  connect() {
    console.log("File manager controller connected", { orderId: this.orderIdValue })
  }

  async removeExistingFile(event) {
    event.preventDefault()
    
    const fileId = event.currentTarget.dataset.fileId
    const orderId = this.orderIdValue
    
    console.log('Delete file attempt:', { fileId, orderId })
    
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
      console.log('Response headers:', Object.fromEntries(response.headers))

      if (!response.ok) {
        const errorText = await response.text()
        console.error('HTTP error response:', errorText)
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      console.log('Response data:', data)

      if (data.success) {
        // Remove the file item from the DOM
        let fileItem = event.currentTarget.closest('div.flex.items-center.justify-between')
        
        console.log('Found file item to remove:', fileItem)
        
        if (fileItem) {
          fileItem.remove()
          console.log('Successfully removed file item from DOM')
          
          // Show success message
          this.showMessage(data.message || 'ファイルが削除されました', 'success')

          // Check if there are no more files and hide the section
          const filesContainer = this.element.querySelector('.mb-4')
          if (filesContainer) {
            const remainingFiles = filesContainer.querySelectorAll('div.flex.items-center.justify-between')
            console.log('Remaining files count:', remainingFiles.length)
            if (remainingFiles.length === 0) {
              filesContainer.style.display = 'none'
              console.log('All files deleted, hiding files container')
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
      console.error('Error details:', {
        message: error.message,
        stack: error.stack,
        fileId: fileId,
        orderId: orderId
      })
      this.showMessage('ファイルの削除中にエラーが発生しました: ' + error.message, 'error')
    }
  }

  showMessage(message, type) {
    // Create a temporary message element
    const messageDiv = document.createElement('div')
    messageDiv.className = `alert ${type === 'success' ? 'alert-success' : 'alert-error'} fixed top-4 right-4 z-50 max-w-sm animate-pulse`
    
    // Add an icon for better visual feedback
    const icon = type === 'success' ? '✅' : '❌'
    messageDiv.innerHTML = `
      <div class="flex items-center space-x-2">
        <span class="text-lg">${icon}</span>
        <span>${message}</span>
      </div>
    `

    document.body.appendChild(messageDiv)
    
    // Log for debugging
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
}