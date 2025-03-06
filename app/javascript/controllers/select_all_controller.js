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
    "statusModal",
    "tableBody",
    "activeTab",
    "tableTitle"
  ]

  connect() {
    this.updateSelectionSummary()
    this.currentStatusElement = null
    // Set the initial active tab
    this.currentTab = "all"
  }

  // Tab switching functionality
  switchTab(event) {
    const tab = event.currentTarget
    this.currentTab = tab.dataset.tab;
    
    // Update active tab styling - first remove active styling from all tabs
    document.querySelectorAll('[data-tab]').forEach(tabEl => {
      tabEl.classList.remove('text-indigo-600', 'border-indigo-600')
      tabEl.classList.add('text-gray-500', 'border-transparent')
    })
    
    // Add active styling to the clicked tab
    tab.classList.remove('text-gray-500', 'border-transparent')
    tab.classList.add('text-indigo-600', 'border-indigo-600')
    
    // Filter table rows
    this.filterRows()
    
    // Reset checkbox selection when switching tabs
    this.clearSelectedRows()
  }

  // Filter table rows based on active tab
  filterRows() {
    const rows = this.tableBodyTarget.querySelectorAll('tr')
    
    rows.forEach(row => {
      const status = row.dataset.status
      
      if (this.currentTab === "all") {
        row.classList.remove('hidden')
      } else if (this.currentTab === "reviewed" && status === "reviewed") {
        row.classList.remove('hidden')
      } else if (this.currentTab === "not-reviewed" && status === "not-reviewed") {
        row.classList.remove('hidden')
      } else {
        row.classList.add('hidden')
      }
    })
  }

  toggleAll(event) {
    const isChecked = event.target.checked

    // Select or deselect only visible row checkboxes based on the header checkbox
    this.checkboxRowTargets.forEach(checkbox => {
      if (!checkbox.closest('tr').classList.contains('hidden')) {
        checkbox.checked = isChecked
      }
    })

    this.updateSelectionSummary()
  }

  checkRowSelection() {
    // Check if all visible row checkboxes are checked
    const visibleCheckboxes = this.checkboxRowTargets.filter(
      cb => !cb.closest('tr').classList.contains('hidden')
    )
    
    const allRowsChecked = visibleCheckboxes.every(checkbox => checkbox.checked)
    
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

    // Manage header checkbox state - only consider visible rows
    const visibleCheckboxes = this.checkboxRowTargets.filter(
      cb => !cb.closest('tr').classList.contains('hidden')
    )
    this.checkboxAllTarget.checked = selectedCount > 0 && 
      selectedCount === visibleCheckboxes.length
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
    const selectedRows = this.checkboxRowTargets.filter(checkbox => checkbox.checked)
    
    // In a real app, you would extract data from the selected rows
    const exportData = `Exporting ${selectedRows.length} rows`
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
    
    // Store the user ID from the row
    this.currentUserId = this.currentStatusElement.closest('tr').dataset.userId

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
    this.currentUserId = null
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

    if (this.currentStatusElement && this.selectedStatus && this.currentUserId) {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      
      // Send AJAX request to update status in database
      fetch(`/career_officer/student_profiles/${this.currentUserId}/update_status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ 
          status: this.selectedStatus 
        })
      })
      .then(response => {
        if (response.ok) {
          // Update the UI with new status
          this.updateStatusUI()
          return response.json()
        } else {
          throw new Error('Status update failed')
        }
      })
      .then(data => {
        console.log('Status updated successfully:', data)
        // If redirect URL is provided, redirect to that URL
        if (data.redirect_url) {
          window.location.href = data.redirect_url
        } else {
          // Otherwise just update the UI
          this.updateStatusUI()
        }
      })
      .catch(error => {
        console.error('Error updating status:', error)
        // Optionally show an error message to the user
      }).finally(() => {
        // Hide loading state if needed
        // this.hideLoadingState()
        
        // Close the modal
        this.closeStatusModal(event)
      })
    }
    
    // Close the modal
    this.closeStatusModal(event)
  }
  
  updateStatusUI() {
    if (!this.currentStatusElement || !this.selectedStatus) return
    
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
    
    // Update the row's data-status attribute for filtering
    const row = this.currentStatusElement.closest('tr')
    row.dataset.status = this.selectedStatus.toLowerCase().replace(' ', '-')
  }
}