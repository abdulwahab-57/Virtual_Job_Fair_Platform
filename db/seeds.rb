# db/seeds.rb

# Remove any existing Career Officer with this email to prevent duplicates
User.where(email: "f219498@cfd.nu.edu.pk").destroy_all

# Create a new Career Officer user with associated profile
career_officer = User.create!(
  full_name: "Career Services Officer",
  email: "f219498@cfd.nu.edu.pk",
  password: "password123",
  password_confirmation: "password123",
  user_type: "career_officer",
  career_officer_profile_attributes: {
    designation: "Career Services Officer",
    phone_number: "+1234567890"
  }
)

puts "Created career officer: #{career_officer.full_name}"

# Load student seed data
load File.join(Rails.root, 'db', 'seeds', 'saeed.rb')
