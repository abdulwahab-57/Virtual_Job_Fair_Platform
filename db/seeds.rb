# Simple seed data for testing the chat feature
puts "Starting simplified seed process..."

# First clear existing test users to avoid conflicts
puts "Clearing existing test users..."
begin
  emails = [
    'career-officer@nu.edu.pk',
    'student1@cfd.nu.edu.pk',
    'student2@cfd.nu.edu.pk',
    'recruiter1@company.com',
    'recruiter2@company.com'
  ]

  # First delete associated records
  User.transaction do
    # Delete any existing conversations and messages
    existing_users = User.where(email: emails)
    Conversation.where(sender_id: existing_users.pluck(:id)).or(
      Conversation.where(recipient_id: existing_users.pluck(:id))
    ).destroy_all

    # Delete the users
    existing_users.destroy_all
  end

  puts "Cleared existing test users"
rescue => e
  puts "Error clearing users: #{e.message}"
end

# Career Officer
puts "Creating Career Officer..."
begin
  career_officer = User.new(
    full_name: 'Career Officer',
    email: 'career-officer@nu.edu.pk',
    password: 'password123',
    password_confirmation: 'password123',
    user_type: 'career_officer',
    confirmed_at: Time.current
  )

  career_officer.build_career_officer_profile(
    designation: 'Senior Career Advisor',
    introduction: 'I help students connect with employers',
    education: 'PhD in Career Counseling',
    office_location: 'Room 301',
    phone_number: '+923001234567'
  )

  career_officer.save!
  puts "Career Officer created successfully"
rescue => e
  puts "Error creating Career Officer: #{e.message}"
end

# Students
puts "Creating Students..."
student_data = [
  {
    full_name: "Ali Ahmad",
    email: "student1@cfd.nu.edu.pk",
    personal_email: "ali.ahmad@gmail.com",
    phone: "+923001111111",
    address: "House 1, Street 5, Lahore",
    linkedin: "https://www.linkedin.com/in/aliahmad"
  },
  {
    full_name: "Fatima Khan",
    email: "student2@cfd.nu.edu.pk",
    personal_email: "fatima.khan@gmail.com",
    phone: "+923002222222",
    address: "House 2, Street 10, Karachi",
    linkedin: "https://www.linkedin.com/in/fatimakhan"
  }
]

student_data.each do |data|
  begin
    student = User.new(
      full_name: data[:full_name],
      email: data[:email],
      password: 'password123',
      password_confirmation: 'password123',
      user_type: 'student',
      confirmed_at: Time.current
    )

    student.build_student_profile(
      email_personal: data[:personal_email],
      phone_number: data[:phone],
      address: data[:address],
      linkedin_url: data[:linkedin]
    )

    student.save!
    puts "Student '#{data[:full_name]}' created successfully"
  rescue => e
    puts "Error creating student #{data[:full_name]}: #{e.message}"
  end
end

# Recruiters
puts "Creating Recruiters..."
recruiter_data = [
  {
    full_name: "Usman Ali",
    email: "recruiter1@company.com",
    company_name: "TechInnovate Solutions",
    industry: "Information Technology",
    about_company: "Leading tech solutions provider",
    office_location: "Blue Area, Islamabad",
    company_email: "careers@techinnovate.com",
    company_website: "https://www.techinnovate.com"
  },
  {
    full_name: "Sarah Malik",
    email: "recruiter2@company.com",
    company_name: "Global Finance Group",
    industry: "Finance",
    about_company: "International financial services company",
    office_location: "Clifton, Karachi",
    company_email: "hr@globalfinance.com",
    company_website: "https://www.globalfinance.com"
  }
]

recruiter_data.each do |data|
  begin
    # Make sure career_officer_confirmed is set to true for recruiter login to work
    recruiter = User.new(
      full_name: data[:full_name],
      email: data[:email],
      password: 'password123',
      password_confirmation: 'password123',
      user_type: 'recruiter',
      confirmed_at: Time.current,
      career_officer_confirmed: true
    )

    recruiter.build_recruiter_profile(
      company_name: data[:company_name],
      industry: data[:industry],
      about_company: data[:about_company],
      office_location: data[:office_location],
      company_email: data[:company_email],
      company_website: data[:company_website]
    )

    recruiter.save!
    puts "Recruiter '#{data[:full_name]}' created successfully with career_officer_confirmed=true"
  rescue => e
    puts "Error creating recruiter #{data[:full_name]}: #{e.message}"
  end
end

puts "Creating a sample conversation..."
begin
  # Get one student and one recruiter
  student = User.find_by(email: 'student1@cfd.nu.edu.pk')
  recruiter = User.find_by(email: 'recruiter1@company.com')

  if student && recruiter
    # Create a conversation
    conversation = Conversation.create!(
      sender_id: student.id,
      recipient_id: recruiter.id
    )

    # Add some messages
    Message.create!(
      body: 'Hello! I am interested in internship opportunities at your company.',
      conversation: conversation,
      user: student,
      read: true
    )

    Message.create!(
      body: 'Hi there! We do have some internship openings. Can you tell me about your skills?',
      conversation: conversation,
      user: recruiter,
      read: false
    )

    puts "Created a sample conversation between student and recruiter"
  end
rescue => e
  puts "Error creating sample conversation: #{e.message}"
end

puts "Seed completed successfully!"

# Login credentials info
puts "\n================================"
puts "TEST LOGIN CREDENTIALS"
puts "================================"
puts "Student: student1@cfd.nu.edu.pk / password123"
puts "Student: student2@cfd.nu.edu.pk / password123"
puts "Recruiter: recruiter1@company.com / password123"
puts "Recruiter: recruiter2@company.com / password123"
puts "Career Officer: career-officer@nu.edu.pk / password123"
puts "================================\n"
