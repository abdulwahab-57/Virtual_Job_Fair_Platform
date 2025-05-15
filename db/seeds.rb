# Create a safer seed environment
puts "Starting seed process..."

# Monkey patch the User model to avoid issues with missing associations
User.class_eval do
  # Skip email domain validation
  def validate_email_domain
    # Skip validation temporarily
  end

  # Override problematic association methods
  def meeting_participants
    # Return empty array instead of accessing the database
    []
  end

  def meetings
    # Return empty array instead of accessing the database
    []
  end
end

# Remove problematic association definitions
if defined?(User) && User.reflections['meeting_participants'].present?
  User.reflections.delete('meeting_participants')
  puts "Removed meeting_participants reflection"
end

if defined?(User) && User.reflections['meetings'].present?
  User.reflections.delete('meetings')
  puts "Removed meetings reflection"
end

puts "Patched User model for seeding"

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
  phone_number: "+923001234567"
)

# Skip the confirmation email and directly confirm the user
career_officer.skip_confirmation!
career_officer.save!

# Confirm the career officer is active
career_officer.confirm!

puts "Career Officer user with profile seeded successfully!"

# Student Seed Data

# First, let's clear any existing test students to avoid duplicates
User.where('email LIKE ?', 'student%@nu.edu.pk').destroy_all

# Student data for the first 10 basic profiles
students_data = [
  {
    full_name: "Ahmed Khan",
    email: "student1@nu.edu.pk",
    email_personal: "ahmed.khan@gmail.com",
    phone_number: "+923001111111",
    address: "House 1, Street 10, Islamabad",
    linkedin_url: "https://www.linkedin.com/in/ahmedkhan"
  },
  {
    full_name: "Fatima Ali",
    email: "student2@nu.edu.pk",
    email_personal: "fatima.ali@gmail.com",
    phone_number: "+923002222222",
    address: "House 2, Street 15, Lahore",
    linkedin_url: "https://www.linkedin.com/in/fatimaali"
  },
  {
    full_name: "Hassan Raza",
    email: "student3@nu.edu.pk",
    email_personal: "hassan.raza@gmail.com",
    phone_number: "+923003333333",
    address: "House 3, Street 20, Karachi",
    linkedin_url: "https://www.linkedin.com/in/hassanraza"
  },
  {
    full_name: "Aisha Malik",
    email: "student4@nu.edu.pk",
    email_personal: "aisha.malik@gmail.com",
    phone_number: "+923004444444",
    address: "House 4, Street 25, Rawalpindi",
    linkedin_url: "https://www.linkedin.com/in/aishamalik"
  },
  {
    full_name: "Omar Farooq",
    email: "student5@nu.edu.pk",
    email_personal: "omar.farooq@gmail.com",
    phone_number: "+923005555555",
    address: "House 5, Street 30, Faisalabad",
    linkedin_url: "https://www.linkedin.com/in/omarfarooq"
  },
  {
    full_name: "Zainab Hussain",
    email: "student6@nu.edu.pk",
    email_personal: "zainab.hussain@gmail.com",
    phone_number: "+923006666666",
    address: "House 6, Street 35, Multan",
    linkedin_url: "https://www.linkedin.com/in/zainabhussain"
  },
  {
    full_name: "Ibrahim Ahmed",
    email: "student7@nu.edu.pk",
    email_personal: "ibrahim.ahmed@gmail.com",
    phone_number: "+923007777777",
    address: "House 7, Street 40, Peshawar",
    linkedin_url: "https://www.linkedin.com/in/ibrahimahmed"
  },
  {
    full_name: "Sara Khalid",
    email: "student8@nu.edu.pk",
    email_personal: "sara.khalid@gmail.com",
    phone_number: "+923008888888",
    address: "House 8, Street 45, Quetta",
    linkedin_url: "https://www.linkedin.com/in/sarakhalid"
  },
  {
    full_name: "Ali Haider",
    email: "student9@nu.edu.pk",
    email_personal: "ali.haider@gmail.com",
    phone_number: "+923009999999",
    address: "House 9, Street 50, Sialkot",
    linkedin_url: "https://www.linkedin.com/in/alihaider"
  },
  {
    full_name: "Mariam Shah",
    email: "student10@nu.edu.pk",
    email_personal: "mariam.shah@gmail.com",
    phone_number: "+923001010101",
    address: "House 10, Street 55, Hyderabad",
    linkedin_url: "https://www.linkedin.com/in/mariamshah"
  }
]

# Create student users and profiles
students_data.each do |student_data|
  student = User.new(
    full_name: student_data[:full_name],
    email: student_data[:email],
    password: "password123",
    password_confirmation: "password123",
    user_type: "student"
  )

  student.build_student_profile(
    email_personal: student_data[:email_personal],
    phone_number: student_data[:phone_number],
    address: student_data[:address],
    linkedin_url: student_data[:linkedin_url]
  )

  # Skip the confirmation email and directly confirm the user
  student.skip_confirmation!
  student.save!

  # Confirm the student is active
  student.confirm!
end

puts "10 Basic student profiles seeded successfully!"

puts "Seed process completed!"
