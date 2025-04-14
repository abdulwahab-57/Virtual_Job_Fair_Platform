export function getCurrentTime() {
  const now = new Date()
  let hours = now.getHours()
  const minutes = now.getMinutes().toString().padStart(2, '0')
  const ampm = hours >= 12 ? 'PM' : 'AM'
  hours = hours % 12 || 12
  return `${hours}:${minutes} ${ampm}`
}

export function createMediaPreview(file, content) {
  const container = document.createElement('div')
  container.className = 'media-container'

  if (file.type.startsWith('image/')) {
    const img = document.createElement('img')
    img.className = 'media-content image'
    img.src = content
    img.onclick = () => openMediaModal(content, 'image')
    container.appendChild(img)
  } 
  else if (file.type.startsWith('video/')) {
    const video = document.createElement('video')
    video.className = 'media-content video'
    video.src = content
    video.controls = true
    container.appendChild(video)
  }
  else if (file.type.startsWith('audio/')) {
    const audio = document.createElement('audio')
    audio.className = 'media-content audio'
    audio.src = content
    audio.controls = true
    container.appendChild(audio)
  }
  else {
    const icon = document.createElement('div')
    icon.className = 'file-icon'
    icon.innerHTML = '📄'
    
    const link = document.createElement('a')
    link.className = 'file-link'
    link.href = content
    link.target = '_blank'
    link.textContent = file.name
    
    container.appendChild(icon)
    container.appendChild(link)
  }

  return container
}

export function openMediaModal(src, type) {
  const modal = document.createElement('div')
  modal.className = 'media-modal'

  const closeButton = document.createElement('span')
  closeButton.className = 'close-modal'
  closeButton.innerHTML = '&times;'
  closeButton.onclick = () => document.body.removeChild(modal)

  let mediaElement
  if (type === 'image') {
    mediaElement = document.createElement('img')
    mediaElement.src = src
  } else {
    mediaElement = document.createElement('video')
    mediaElement.src = src
    mediaElement.controls = true
    mediaElement.autoplay = true
  }

  modal.appendChild(closeButton)
  modal.appendChild(mediaElement)
  document.body.appendChild(modal)
}

export function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i])
}