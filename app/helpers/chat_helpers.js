// Time formatting
export function getCurrentTime() {
    const now = new Date()
    let hours = now.getHours()
    const minutes = now.getMinutes().toString().padStart(2, "0")
    const ampm = hours >= 12 ? "PM" : "AM"
    hours = hours % 12 || 12
    return `${hours}:${minutes} ${ampm}`
  }
  
  // DOM manipulation helpers
  export function createElement(tag, classes = [], attributes = {}) {
    const element = document.createElement(tag)
    if (classes.length) element.classList.add(...classes)
    Object.entries(attributes).forEach(([key, value]) => {
      element.setAttribute(key, value)
    })
    return element
  }
  
  export function scrollToBottom(element) {
    if (element) {
      element.scrollTop = element.scrollHeight
    }
  }
  
  // Media helpers
  export function createMediaPreview(file) {
    const previewMap = {
      'image/': createImagePreview,
      'video/': createVideoPreview,
      'default': createDocumentPreview
    }
  
    const creator = Object.entries(previewMap)
      .find(([type]) => file.type.startsWith(type))?.[1] || previewMap.default
  
    return creator(file)
  }
  
  function createImagePreview(file) {
    const img = createElement('img', ['whatsapp-image'], {
      src: URL.createObjectURL(file)
    })
    return img
  }
  
  function createVideoPreview(file) {
    const video = createElement('video', ['whatsapp-video'], {
      src: URL.createObjectURL(file),
      controls: true
    })
    return video
  }
  
  function createDocumentPreview(file) {
    const container = createElement('div', ['whatsapp-document'])
    const icon = createElement('span', ['document-icon'])
    icon.innerHTML = "📄"
    
    const link = createElement('a', ['document-name'], {
      href: URL.createObjectURL(file),
      target: "_blank"
    })
    link.textContent = file.name
  
    container.append(icon, link)
    return container
  }
  
  // Modal helpers
  export function openImageModal(src) {
    const modal = createElement('div', ['image-modal'])
    const img = createElement('img', [], {
      src,
      style: "max-width: 90vw; max-height: 90vh;"
    })
    
    const closeButton = createElement('span', ['close-modal'])
    closeButton.innerHTML = "&times;"
    closeButton.onclick = () => document.body.removeChild(modal)
  
    modal.append(closeButton, img)
    document.body.appendChild(modal)
  }
  
  // Local storage helpers
  export function saveToLocalStorage(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value))
      return true
    } catch (e) {
      console.error("LocalStorage save failed:", e)
      return false
    }
  }
  
  export function loadFromLocalStorage(key) {
    try {
      const data = localStorage.getItem(key)
      return data ? JSON.parse(data) : null
    } catch (e) {
      console.error("LocalStorage load failed:", e)
      return null
    }
  }