# Career Officer Seed Data

# Remove existing user if it exists
User.where(email: "career-officer@nu.edu.pk").destroy_all

# Create a new Career Officer user
career_officer = User.new(
  full_name: "Career Services Officer",
  email: "career-officer@nu.edu.pk",
  password: "password123",
  password_confirmation: "password123",
  user_type: "career_officer"
)

# Skip email confirmation (if using Devise confirmable)
career_officer.skip_confirmation! if career_officer.respond_to?(:skip_confirmation!)
career_officer.save!

# Confirm the user (optional, only if confirmable module is used)
career_officer.confirm! if career_officer.respond_to?(:confirm!)

puts "Career Officer user registered successfully!"
