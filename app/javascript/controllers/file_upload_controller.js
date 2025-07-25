import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropZone", "selectedContainer", "selectedList"]
  
  connect() {
    console.log("File upload controller connected")
    this.reset()
  }
  
  disconnect() {
    console.log("File upload controller disconnected")
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
    
    // Reset drop zone text
    this.resetDropZoneText()
  }
  
  click(event) {
    console.log('Drop zone clicked')
    if (this.hasInputTarget) {
      this.inputTarget.click()
    }
  }
  
  change(event) {
    console.log('File input changed with files:', event.target.files.length)
    if (event.target.files.length > 0) {
      this.displaySelectedFiles(event.target.files)
    } else {
      this.reset()
    }
  }
  
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
      this.displaySelectedFiles(files)
    }
  }
  
  displaySelectedFiles(files) {
    if (!this.hasSelectedContainerTarget || !this.hasSelectedListTarget) {
      return
    }
    
    // Clear previous selection display
    this.selectedListTarget.innerHTML = ''
    
    // Show the container
    this.selectedContainerTarget.classList.remove('hidden')
    
    // Display each file
    Array.from(files).forEach((file, index) => {
      const fileItem = document.createElement('div')
      fileItem.className = 'flex items-center justify-between p-2 bg-gray-50 rounded-lg'
      fileItem.dataset.fileIndex = index
      
      const fileInfo = document.createElement('div')
      fileInfo.className = 'flex items-center space-x-2'
      
      const fileName = document.createElement('span')
      fileName.className = 'text-sm text-gray-700'
      fileName.textContent = file.name
      
      const fileSize = document.createElement('span')
      fileSize.className = 'text-xs text-gray-500'
      fileSize.textContent = this.formatFileSize(file.size)
      
      fileInfo.appendChild(fileName)
      fileInfo.appendChild(fileSize)
      
      const deleteButton = document.createElement('button')
      deleteButton.type = 'button'
      deleteButton.className = 'text-xs text-red-600 hover:text-red-700'
      deleteButton.textContent = '削除'
      deleteButton.addEventListener('click', () => this.removeFile(index))
      
      fileItem.appendChild(fileInfo)
      fileItem.appendChild(deleteButton)
      this.selectedListTarget.appendChild(fileItem)
    })
    
    // Update drop zone text
    this.updateDropZoneText(files.length)
  }
  
  removeFile(index) {
    // Get current files
    const currentFiles = Array.from(this.inputTarget.files)
    currentFiles.splice(index, 1)
    
    // Update the file input with remaining files
    const dt = new DataTransfer()
    currentFiles.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files
    
    // Redisplay the files
    if (currentFiles.length > 0) {
      this.displaySelectedFiles(dt.files)
    } else {
      this.reset()
    }
  }
  
  updateDropZoneText(fileCount) {
    const dropZoneText = this.dropZoneTarget.querySelector('p.text-gray-600')
    if (dropZoneText) {
      dropZoneText.innerHTML = `
        <span class="font-medium text-green-600">${fileCount}個のファイルが選択されました</span>
        <span class="text-gray-500">（別のファイルを選択するにはクリックまたはドラッグ＆ドロップ）</span>
      `
    }
  }
  
  resetDropZoneText() {
    const dropZoneText = this.dropZoneTarget.querySelector('p.text-gray-600')
    if (dropZoneText) {
      dropZoneText.innerHTML = `
        <span class="font-medium text-blue-600 hover:text-blue-500">クリックしてファイルを選択</span>
        <span class="text-gray-500">またはここにファイルをドラッグ＆ドロップ</span>
      `
    }
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}