import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["messages", "input", "form", "mentionList"]
  static values = { 
    orderId: Number,
    currentUserId: Number,
    currentUserName: String
  }

  connect() {
    this.consumer = createConsumer()
    this.subscription = null
    this.mentionUsers = []
    this.showingMentions = false
    this.mentionStartIndex = -1
    
    this.connectToChannel()
    this.loadMessages()
    this.setupMentionHandling()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  connectToChannel() {
    this.subscription = this.consumer.subscriptions.create(
      {
        channel: "OrderChatChannel",
        order_id: this.orderIdValue
      },
      {
        received: (data) => {
          this.appendMessage(data)
          this.scrollToBottom()
        }
      }
    )
  }

  async loadMessages() {
    try {
      const response = await fetch(`/orders/${this.orderIdValue}/chat_messages`)
      const messages = await response.json()
      
      this.messagesTarget.innerHTML = ""
      messages.forEach(message => this.appendMessage(message))
      this.scrollToBottom()
    } catch (error) {
      console.error("Failed to load messages:", error)
    }
  }

  appendMessage(messageData) {
    const messageElement = document.createElement("div")
    messageElement.className = "chat " + (messageData.user.id === this.currentUserIdValue ? "chat-end" : "chat-start")
    
    const isCurrentUser = messageData.user.id === this.currentUserIdValue
    
    messageElement.innerHTML = `
      <div class="chat-image avatar">
        <div class="w-8 rounded-full bg-neutral text-neutral-content flex items-center justify-center">
          <span class="text-xs">${messageData.user.avatar_initial}</span>
        </div>
      </div>
      <div class="chat-header">
        ${messageData.user.name}
        <time class="text-xs opacity-50 ml-1">${messageData.created_at}</time>
      </div>
      <div class="chat-bubble ${isCurrentUser ? 'chat-bubble-primary' : ''}">${messageData.content}</div>
    `
    
    this.messagesTarget.appendChild(messageElement)
  }

  sendMessage(event) {
    event.preventDefault()
    
    const content = this.inputTarget.value.trim()
    if (!content) return

    // Send via Action Cable
    this.subscription.perform("send_message", { content: content })
    
    // Clear input
    this.inputTarget.value = ""
    this.hideMentionList()
  }

  setupMentionHandling() {
    this.inputTarget.addEventListener("input", this.handleInput.bind(this))
    this.inputTarget.addEventListener("keydown", this.handleKeydown.bind(this))
    
    // Click outside to hide mention list
    document.addEventListener("click", (e) => {
      if (!this.element.contains(e.target)) {
        this.hideMentionList()
      }
    })
  }

  async handleInput(event) {
    const input = event.target
    const cursorPosition = input.selectionStart
    const textBeforeCursor = input.value.substring(0, cursorPosition)
    
    // Check for @ mention
    const mentionMatch = textBeforeCursor.match(/@(\w*)$/)
    
    if (mentionMatch) {
      const query = mentionMatch[1]
      this.mentionStartIndex = cursorPosition - mentionMatch[0].length
      
      try {
        const response = await fetch(`/orders/${this.orderIdValue}/chat_messages/users_for_mention?q=${encodeURIComponent(query)}`)
        const users = await response.json()
        this.showMentionList(users)
      } catch (error) {
        console.error("Failed to fetch users:", error)
        this.hideMentionList()
      }
    } else {
      this.hideMentionList()
    }
  }

  handleKeydown(event) {
    if (!this.showingMentions) return

    const mentionItems = this.mentionListTarget.querySelectorAll(".mention-item")
    let selectedIndex = Array.from(mentionItems).findIndex(item => item.classList.contains("selected"))

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        selectedIndex = (selectedIndex + 1) % mentionItems.length
        this.updateSelection(mentionItems, selectedIndex)
        break
        
      case "ArrowUp":
        event.preventDefault()
        selectedIndex = selectedIndex <= 0 ? mentionItems.length - 1 : selectedIndex - 1
        this.updateSelection(mentionItems, selectedIndex)
        break
        
      case "Tab":
      case "Enter":
        event.preventDefault()
        const selectedItem = mentionItems[selectedIndex >= 0 ? selectedIndex : 0]
        if (selectedItem) {
          this.selectMention(selectedItem.dataset.userName)
        }
        break
        
      case "Escape":
        event.preventDefault()
        this.hideMentionList()
        break
    }
  }

  showMentionList(users) {
    if (users.length === 0) {
      this.hideMentionList()
      return
    }

    this.showingMentions = true
    
    this.mentionListTarget.innerHTML = users.map((user, index) => `
      <div class="mention-item p-2 cursor-pointer hover:bg-gray-100 ${index === 0 ? 'selected bg-blue-100' : ''}" 
           data-user-name="${user.name}"
           data-action="click->order-chat#selectMentionEvent">
        <div class="flex items-center">
          <div class="w-6 h-6 rounded-full bg-neutral text-neutral-content flex items-center justify-center mr-2">
            <span class="text-xs">${user.name[0]}</span>
          </div>
          <span class="font-medium">${user.display_name}</span>
          <span class="text-gray-500 text-sm ml-2">${user.email}</span>
        </div>
      </div>
    `).join("")
    
    this.mentionListTarget.classList.remove("hidden")
    
    // Position the mention list
    this.positionMentionList()
  }

  hideMentionList() {
    this.showingMentions = false
    this.mentionListTarget.classList.add("hidden")
    this.mentionStartIndex = -1
  }

  selectMentionEvent(event) {
    const userName = event.currentTarget.dataset.userName
    this.selectMention(userName)
  }

  selectMention(userName) {
    const input = this.inputTarget
    const currentValue = input.value
    const beforeMention = currentValue.substring(0, this.mentionStartIndex)
    const afterCursor = currentValue.substring(input.selectionStart)
    
    const newValue = beforeMention + `@${userName} ` + afterCursor
    input.value = newValue
    
    // Set cursor position after the mention
    const newCursorPosition = beforeMention.length + userName.length + 2
    input.setSelectionRange(newCursorPosition, newCursorPosition)
    
    this.hideMentionList()
    input.focus()
  }

  updateSelection(items, selectedIndex) {
    items.forEach((item, index) => {
      if (index === selectedIndex) {
        item.classList.add("selected", "bg-blue-100")
        item.classList.remove("bg-gray-100")
      } else {
        item.classList.remove("selected", "bg-blue-100")
      }
    })
  }

  positionMentionList() {
    // Position mention list above the input
    const inputRect = this.inputTarget.getBoundingClientRect()
    const listRect = this.mentionListTarget.getBoundingClientRect()
    
    // Position above the input
    this.mentionListTarget.style.position = "fixed"
    this.mentionListTarget.style.left = `${inputRect.left}px`
    this.mentionListTarget.style.bottom = `${window.innerHeight - inputRect.top + 5}px`
    this.mentionListTarget.style.width = `${Math.max(300, inputRect.width)}px`
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}