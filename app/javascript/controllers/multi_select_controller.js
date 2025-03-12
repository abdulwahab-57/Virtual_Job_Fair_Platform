import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multi-select"
export default class extends Controller {
  static targets = ["select"]
  static values = {
    placeholder: { type: String, default: "Select options" }
  }

  connect() {
    console.log("Multi-select controller connected")
    this.initializeMultiSelect()
  }

  initializeMultiSelect() {
    if (!this.hasSelectTarget) {
      console.error("Select target not found")
      return
    }

    // Hide the original select
    this.selectTarget.style.display = 'none'
    
    // Create container
    const container = document.createElement('div')
    container.className = 'relative w-full'
    this.selectTarget.parentNode.insertBefore(container, this.selectTarget)
    
    // Create the display field
    const field = document.createElement('div')
    field.className = 'border border-gray-300 rounded p-2 bg-white cursor-pointer flex items-center justify-between'
    field.innerHTML = `
      <span class="placeholder">${this.placeholderValue}</span>
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>
    `
    container.appendChild(field)
    
    // Create the dropdown
    const dropdown = document.createElement('div')
    dropdown.className = 'absolute z-50 w-full mt-1 bg-white border border-gray-300 rounded shadow-lg hidden'
    dropdown.style.maxHeight = '300px'
    dropdown.style.overflowY = 'auto'
    container.appendChild(dropdown)
    
    // Add search input
    const searchContainer = document.createElement('div')
    searchContainer.className = 'p-2 border-b border-gray-200'
    dropdown.appendChild(searchContainer)
    
    const searchInput = document.createElement('input')
    searchInput.type = 'text'
    searchInput.className = 'w-full p-2 border border-gray-300 rounded'
    searchInput.placeholder = 'Search...'
    searchContainer.appendChild(searchInput)
    
    // Create options container
    const optionsContainer = document.createElement('div')
    optionsContainer.className = 'options-container'
    dropdown.appendChild(optionsContainer)
    
    // Add options
    const options = Array.from(this.selectTarget.options)
    if (options.length === 0) {
      const noOptions = document.createElement('div')
      noOptions.className = 'p-3 text-center text-gray-500'
      noOptions.textContent = 'No options available'
      optionsContainer.appendChild(noOptions)
    } else {
      options.forEach(option => {
        if (option.value) {
          const optionElement = document.createElement('div')
          optionElement.className = 'p-2 hover:bg-blue-50 cursor-pointer border-b border-gray-100 last:border-b-0'
          optionElement.dataset.value = option.value
          optionElement.textContent = option.text
          
          if (option.selected) {
            optionElement.classList.add('bg-blue-100')
          }
          
          optionElement.addEventListener('click', () => {
            // Toggle selection
            option.selected = !option.selected
            optionElement.classList.toggle('bg-blue-100')
            
            // Update display
            this.updateDisplay(field, options)
            
            // Trigger change event
            this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
          })
          
          optionsContainer.appendChild(optionElement)
        }
      })
    }
    
    // Toggle dropdown on field click
    field.addEventListener('click', () => {
      dropdown.classList.toggle('hidden')
      if (!dropdown.classList.contains('hidden')) {
        searchInput.focus()
      }
    })
    
    // Filter options on search
    searchInput.addEventListener('input', () => {
      const searchTerm = searchInput.value.toLowerCase()
      const optionElements = optionsContainer.querySelectorAll('div[data-value]')
      
      let hasVisibleOptions = false
      optionElements.forEach(el => {
        const text = el.textContent.toLowerCase()
        if (text.includes(searchTerm)) {
          el.style.display = 'block'
          hasVisibleOptions = true
        } else {
          el.style.display = 'none'
        }
      })
      
      // Show/hide no results message
      let noResults = optionsContainer.querySelector('.no-results')
      if (!hasVisibleOptions) {
        if (!noResults) {
          noResults = document.createElement('div')
          noResults.className = 'no-results p-3 text-center text-gray-500'
          noResults.textContent = 'No matching options'
          optionsContainer.appendChild(noResults)
        } else {
          noResults.style.display = 'block'
        }
      } else if (noResults) {
        noResults.style.display = 'none'
      }
    })
    
    // Close dropdown when clicking outside
    document.addEventListener('click', (event) => {
      if (!container.contains(event.target)) {
        dropdown.classList.add('hidden')
      }
    })
    
    // Initial display update
    this.updateDisplay(field, options)
  }
  
  updateDisplay(field, options) {
    const selectedOptions = options.filter(opt => opt.selected)
    const placeholder = field.querySelector('.placeholder')
    
    // Remove any existing tags container
    const existingTagsContainer = field.querySelector('.tags-container')
    if (existingTagsContainer) {
      existingTagsContainer.remove()
    }
    
    if (selectedOptions.length === 0) {
      placeholder.textContent = this.placeholderValue
      placeholder.style.display = 'block'
    } else {
      placeholder.style.display = 'none'
      
      // Add selected tags
      const tagsContainer = document.createElement('div')
      tagsContainer.className = 'tags-container flex flex-wrap gap-1'
      
      selectedOptions.forEach(option => {
        const tag = document.createElement('span')
        tag.className = 'selected-tag bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm flex items-center'
        tag.innerHTML = `
          ${option.text}
          <button type="button" class="ml-1 text-blue-600 hover:text-blue-800 font-bold">&times;</button>
        `
        
        // Remove tag on button click
        const removeButton = tag.querySelector('button')
        removeButton.addEventListener('click', (e) => {
          e.stopPropagation() // Prevent dropdown toggle
          
          // Find the option in the select element and deselect it
          const selectOption = Array.from(this.selectTarget.options).find(opt => opt.value === option.value)
          if (selectOption) {
            selectOption.selected = false
          }
          
          // Remove the tag directly from the DOM
          tag.remove()
          
          // If no tags left, remove the container and show placeholder
          if (tagsContainer.children.length === 0) {
            tagsContainer.remove()
            placeholder.style.display = 'block'
          }
          
          // Trigger change event on the select element
          this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
        })
        
        tagsContainer.appendChild(tag)
      })
      
      // Insert before the SVG icon
      field.insertBefore(tagsContainer, field.querySelector('svg'))
    }
  }
  
  disconnect() {
    // Clean up event listeners if needed
  }
} 