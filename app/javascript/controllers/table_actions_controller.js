import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table-actions"
export default class extends Controller {
  static targets = [
    "checkboxAll",
    "checkboxRow",
    "selectionSummary",
    "selectedCount",
    "clearSelection",
    "actionsSelect",
    "statusModal",
    "tableBody"
  ]

  connect() {
    this.currentStatusElement = null
    this.currentUserId = null
    this.selectedStatus = null
    this.updateSelectionSummary()
  }

  toggleAll(event) {
    const isChecked = event.target.checked
    this.checkboxRowTargets.forEach(checkbox => {
      checkbox.checked = isChecked
    })
    this.updateSelectionSummary()
  }

  checkRowSelection() {
    const allChecked = this.checkboxRowTargets.length > 0 &&
      this.checkboxRowTargets.every(cb => cb.checked)
    this.checkboxAllTarget.checked = allChecked
    this.updateSelectionSummary()
  }

  updateSelectionSummary() {
    const selectedRows = this.checkboxRowTargets.filter(cb => cb.checked)
    const count = selectedRows.length

    if (count > 0) {
      this.selectionSummaryTarget.classList.remove("hidden")
      this.selectedCountTarget.textContent = count
    } else {
      this.selectionSummaryTarget.classList.add("hidden")
    }

    this.checkboxAllTarget.checked = count > 0 &&
      count === this.checkboxRowTargets.length
  }

  clearSelectedRows() {
    this.checkboxRowTargets.forEach(cb => { cb.checked = false })
    this.checkboxAllTarget.checked = false
    this.selectionSummaryTarget.classList.add("hidden")
    this.actionsSelectTarget.selectedIndex = 0
  }

  performAction() {
    const action = this.actionsSelectTarget.value
    const selected = this.checkboxRowTargets.filter(cb => cb.checked)

    if (action === "download_profiles") {
      this.downloadProfiles(selected)
    }

    this.actionsSelectTarget.selectedIndex = 0
  }

  downloadProfiles(selectedCheckboxes) {
    const userIds = selectedCheckboxes.map(cb => cb.closest("tr").dataset.userId)

    if (userIds.length === 0) return

    const baseUrl = "/career_officer/student_profiles/download_profiles.pdf"
    const query = userIds.map(id => `user_ids[]=${id}`).join("&")
    const url = `${baseUrl}?${query}`

    const link = document.createElement("a")
    link.href = url
    link.setAttribute("data-method", "post")
    link.setAttribute("data-remote", "false")

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content")
    const csrfParam = document.querySelector('meta[name="csrf-param"]').getAttribute("content")
    link.setAttribute(`data-${csrfParam}`, csrfToken)

    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  openStatusModal(event) {
    event.stopPropagation()

    this.currentStatusElement = event.currentTarget
    this.currentUserId = this.currentStatusElement.closest("tr").dataset.userId

    this.statusModalTarget.classList.remove("hidden")
  }

  closeStatusModal(event) {
    if (event) event.stopPropagation()

    this.statusModalTarget.classList.add("hidden")
    this.currentStatusElement = null
    this.currentUserId = null
  }

  changeStatus(event) {
    event.stopPropagation()

    event.currentTarget.parentElement.querySelectorAll("button").forEach(btn => {
      btn.classList.remove("bg-gray-200")
    })
    event.currentTarget.classList.add("bg-gray-200")

    this.selectedStatus = event.currentTarget.dataset.status
  }

  applyStatus(event) {
    event.stopPropagation()

    if (!this.currentStatusElement || !this.selectedStatus || !this.currentUserId) return

    // Capture references before closing the modal clears them
    const statusElement = this.currentStatusElement
    const status = this.selectedStatus
    const userId = this.currentUserId

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content")

    fetch(`/career_officer/student_profiles/${userId}/update_status`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ status })
    })
      .then(response => {
        if (!response.ok) throw new Error("Status update failed")
        return response.json()
      })
      .then(data => {
        this.updateStatusElement(statusElement, status)
        if (data.redirect_url) {
          window.location.href = data.redirect_url
        }
      })
      .catch(error => {
        console.error("Error updating status:", error)
      })
      .finally(() => {
        this.closeStatusModal()
      })
  }

  updateStatusElement(element, status) {
    element.textContent = status

    const colorMap = {
      "Reviewed": "bg-gray-100 text-gray-800",
      "Not Reviewed": "bg-red-100 text-red-800"
    }

    // Remove existing bg-* and text-* color classes without a fragile regex
    const filtered = element.className
      .split(" ")
      .filter(c => !c.match(/^bg-\w+-\d+$/) && !c.match(/^text-\w+-\d+$/))
      .join(" ")
    element.className = filtered

    const newClasses = colorMap[status]
    if (newClasses) {
      element.classList.add(...newClasses.split(" "))
    }

    const row = element.closest("tr")
    if (row) row.dataset.status = status.toLowerCase().replace(" ", "-")
  }
}
