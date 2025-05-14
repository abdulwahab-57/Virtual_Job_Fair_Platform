# Standalone seed file to create recruiters and career officers directly
# Run this with: bundle exec rails runner db/seed_directly.rb

# First define any missing models to avoid association errors
unless defined?(MeetingParticipant)
  class MeetingParticipant < ActiveRecord::Base
    self.abstract_class = true
  end
  puts "Defined MeetingParticipant placeholder"
end

unless defined?(Meeting)
  class Meeting < ActiveRecord::Base
    self.abstract_class = true
  end
  puts "Defined Meeting placeholder"
end

# Skip validation for domain temporarily
User.class_eval do
  def validate_email_domain
    # Skip validation temporarily
  end
end

puts "Patched User model for validation"

# Sample company data
companies = [
  { name: "Tech Innovations", industry: "Technology", description: "Leading software development company", website: "https://techinnovations.com" },
  { name: "Global Finance", industry: "Finance", description: "International financial services provider", website: "https://globalfinance.com" },
  { name: "Health Solutions", industry: "Healthcare", description: "Healthcare technology and services", website: "https://healthsolutions.com" },
  { name: "Creative Media", industry: "Media", description: "Digital and traditional media production", website: "https://creativemedia.com" },
  { name: "EduTech Systems", industry: "Education", description: "Educational technology solutions", website: "https://edutechsystems.com" },
  { name: "Green Energy", industry: "Energy", description: "Renewable energy solutions provider", website: "https://greenenergy.com" },
  { name: "Construction Partners", industry: "Construction", description: "Building and infrastructure development", website: "https://constructionpartners.com" },
  { name: "Retail Networks", industry: "Retail", description: "Retail chain and e-commerce solutions", website: "https://retailnetworks.com" },
  { name: "Travel Experiences", industry: "Travel", description: "Travel and hospitality services", website: "https://travelexperiences.com" },
  { name: "Telecom Solutions", industry: "Telecommunications", description: "Telecommunications infrastructure and services", website: "https://telecomsolutions.com" }
]

puts "Creating 10 recruiter profiles..."

# Create 10 recruiters with company profiles
10.times do |i|
  company = companies[i]

  # Skip if email already exists
  if User.exists?(email: "recruiter#{i+1}@example.com")
    puts "Recruiter #{i+1} already exists, skipping"
    next
  end

  # Create recruiter user
  recruiter = User.new(
    full_name: Faker::Name.name,
    email: "recruiter#{i+1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    user_type: "recruiter"
  )

  # Create recruiter profile with company
  recruiter.build_recruiter_profile(
    position: [ "HR Manager", "Talent Acquisition Specialist", "Recruitment Lead", "HR Director", "HR Business Partner" ].sample,
    phone_number: "+92300#{Faker::Number.number(digits: 7)}",
    company_name: company[:name],
    company_industry: company[:industry],
    company_description: company[:description],
    company_website: company[:website],
    linkedin_url: "https://www.linkedin.com/in/#{Faker::Internet.username}"
  )

  # Skip confirmation email
  recruiter.skip_confirmation!
  recruiter.save!

  # Confirm the recruiter is active
  recruiter.confirm!

  puts "Created recruiter: #{recruiter.full_name} from #{company[:name]}"
end

puts "Creating 5 additional career officers..."

# Create 5 additional career officers with diverse profiles
5.times do |i|
  # Skip if email already exists
  if User.exists?(email: "career-officer#{i+2}@nu.edu.pk")
    puts "Career officer #{i+2} already exists, skipping"
    next
  end

  # Create career officer user
  career_officer = User.new(
    full_name: Faker::Name.name,
    email: "career-officer#{i+2}@nu.edu.pk", # Starting from 2 since we assume 1 already exists
    password: "password123",
    password_confirmation: "password123",
    user_type: "career_officer"
  )

  # Create career officer profile
  specialties = [
    "Technical Career Counseling",
    "Interview Preparation",
    "Resume Building",
    "Industry Networking",
    "Graduate Studies Advising",
    "Career Assessment",
    "Job Market Research",
    "Internship Coordination",
    "Alumni Relations",
    "Professional Development"
  ]

  # Select 2-3 random specialties
  selected_specialties = specialties.sample(rand(2..3)).join(", ")

  # Create profile with varied information
  career_officer.build_career_officer_profile(
    designation: [ "Senior Career Advisor", "Career Development Specialist", "Career Counselor", "Employment Services Coordinator", "Career Planning Officer" ].sample,
    introduction: "Helping students navigate their career paths and achieve professional success. Specializing in #{selected_specialties}.",
    education: [ "PhD in Career Counseling", "MBA, HR Management", "MS in Counseling Psychology", "MA in Higher Education Administration" ].sample,
    office_location: "Room #{rand(100..399)}, #{[ 'Admin Building', 'Student Affairs Center', 'Career Services Wing' ].sample}",
    phone_number: "+92300#{Faker::Number.number(digits: 7)}"
  )

  # Skip confirmation email
  career_officer.skip_confirmation!
  career_officer.save!

  # Confirm the career officer is active
  career_officer.confirm!

  puts "Created career officer: #{career_officer.full_name}, #{career_officer.career_officer_profile.designation}"
end

puts "Successfully created recruiters and additional career officers!"
