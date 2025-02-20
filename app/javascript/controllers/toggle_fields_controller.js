import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-fields"
export default class extends Controller {
  static targets = ["studentFields", "recruiterFields", "careerOfficerFields", "userType"];

  connect() {
    //console.log("Toggle Fields Controller Connected"); 
    // console.log("Targets found:", this.hasStudentFieldsTarget, this.hasRecruiterFieldsTarget, this.hasCareerOfficerFieldsTarget);
    this.toggle(); // Ensure fields are shown/hidden on page load
  }

  toggle() {
    const userType = this.userTypeTarget.value;

    // Hide all fields initially
    this.studentFieldsTarget.style.display = "none";
    this.recruiterFieldsTarget.style.display = "none";
    this.careerOfficerFieldsTarget.style.display = "none";

    // Show the relevant fields
    if (userType === "student") {
      this.studentFieldsTarget.style.display = "block";
    } else if (userType === "recruiter") {
      this.recruiterFieldsTarget.style.display = "block";
    } else if (userType === "career_officer") {
      this.careerOfficerFieldsTarget.style.display = "block";
    }
  }
}
