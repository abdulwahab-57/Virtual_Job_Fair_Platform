# Career Officer Seed Data

# First, let's clear any existing career officer with this email to avoid duplicates
User.where(email: "career-officer@nu.edu.pk").destroy_all

# Creating a Career Officer User
career_officer = User.new(
  full_name: "Career Services Officer",
  email: "career-officer@nu.edu.pk",
  password: "password123",
  password_confirmation: "password123",
  user_type: "career_officer"
)

# Create the associated career officer profile
career_officer.build_career_officer_profile(
  designation: "Senior Career Advisor",
  introduction: "I help students connect with potential employers and prepare for their professional careers.",
  education: "PhD in Career Counseling, MBA",
  office_location: "Room 301, Admin Building",
  phone_number: "+92 300 1234567"
)

# Skip the confirmation email and directly confirm the user
career_officer.skip_confirmation!
career_officer.save!

# Confirm the career officer is active
career_officer.confirm!

puts "Career Officer user with profile seeded successfully!"
