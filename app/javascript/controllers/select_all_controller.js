import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-all"
export default class extends Controller {
  
  static targets = [ 
    "checkboxAll", 
    "checkboxRow", 
    "selectionSummary", 
    "selectedCount", 
    "clearSelection",
    "actionsSelect",
    "statusModal"
  ]

  connect() {
    this.updateSelectionSummary()
    this.currentStatusElement = null
  }


  toggleAll(event) {
    const isChecked = event.target.checked

    // Select or deselect all row checkboxes based on the header checkbox
    this.checkboxRowTargets.forEach(checkbox => {
      checkbox.checked = isChecked
    })

    this.updateSelectionSummary()
  }

  checkRowSelection() {
    // Check if all row checkboxes are checked
    const allRowsChecked = this.checkboxRowTargets.every(checkbox => checkbox.checked)
    
    // Update the header checkbox accordingly
    this.checkboxAllTarget.checked = allRowsChecked

    this.updateSelectionSummary()
  }

  updateSelectionSummary() {
    // Count selected rows
    const selectedRows = this.checkboxRowTargets.filter(checkbox => checkbox.checked)
    const selectedCount = selectedRows.length

    // Update selection summary
    if (selectedCount > 0) {
      this.selectionSummaryTarget.classList.remove('hidden')
      this.selectedCountTarget.textContent = selectedCount
    } else {
      this.selectionSummaryTarget.classList.add('hidden')
    }

    // Manage header checkbox state
    this.checkboxAllTarget.checked = selectedCount === this.checkboxRowTargets.length
  }

  clearSelectedRows() {
    // Uncheck all row checkboxes
    this.checkboxRowTargets.forEach(checkbox => {
      checkbox.checked = false
    })

    // Uncheck header checkbox
    this.checkboxAllTarget.checked = false

    // Hide selection summary
    this.selectionSummaryTarget.classList.add('hidden')

    // Reset select to default
    this.actionsSelectTarget.selectedIndex = 0
  }

  performAction() {
    const selectedAction = this.actionsSelectTarget.value
    const selectedRows = this.checkboxRowTargets.filter(checkbox => checkbox.checked)

    switch(selectedAction) {
      case 'export':
        this.exportSelected(selectedRows)
        break
      case 'delete':
        this.deleteSelected(selectedRows)
        break
    }

    // Reset select to default
    this.actionsSelectTarget.selectedIndex = 0
  }

  // Actions on selected rows
  deleteSelected() {
    // Implement delete logic for selected rows
    const selectedRows = this.checkboxRowTargets.filter(checkbox => checkbox.checked)
    console.log(`Deleting ${selectedRows.length} selected rows`)
    
    // Remove selected rows from the table (example implementation)
    selectedRows.forEach(checkbox => {
      const row = checkbox.closest('tr')
      row.remove()
    })

    this.updateSelectionSummary()
  }

  exportSelected() {
    // Implement export logic for selected rows
    
    console.log('Exporting selected rows:', exportData)
    // In a real application, you'd implement actual export logic here
    // For example, converting to CSV or sending to a backend service
  }

  openStatusModal(event) {
    // Prevent event propagation
    event.stopPropagation()
    
    console.log("Modal should open now!", this.statusModalTarget);

    // Store the clicked status element
    this.currentStatusElement = event.currentTarget

    // Show the status modal
    this.statusModalTarget.classList.remove('hidden')
  }

  closeStatusModal(event) {
    // Prevent event propagation
    event.stopPropagation()

    // Hide the status modal
    this.statusModalTarget.classList.add('hidden')
    
    // Reset the current status element
    this.currentStatusElement = null
  }

  changeStatus(event) {
    // Prevent event propagation
    event.stopPropagation()

    // Remove active state from all buttons
    event.currentTarget.parentElement.querySelectorAll('button').forEach(btn => {
      btn.classList.remove('bg-gray-200')
    })
    
    // Add active state to clicked button
    event.currentTarget.classList.add('bg-gray-200')
    
    // Store the selected status
    this.selectedStatus = event.currentTarget.dataset.status
  }

  applyStatus(event) {
    // Prevent event propagation
    event.stopPropagation()

    if (this.currentStatusElement && this.selectedStatus) {
      // Update the status text
      this.currentStatusElement.textContent = this.selectedStatus
      
      // Update background color based on status
      const colorMap = {
        'Reviewed': 'bg-gray-100 text-gray-800',
        'Not Reviewed': 'bg-red-100 text-red-800'
      }
      
      // Remove previous color classes
      this.currentStatusElement.className = this.currentStatusElement.className
        .replace(/bg-\w+-\d+\s+text-\w+-\d+/, '')
      
      // Add new color classes
      this.currentStatusElement.classList.add(...colorMap[this.selectedStatus].split(' '))
    }
    
    // Close the modal
    this.closeStatusModal(event)
  }

}
