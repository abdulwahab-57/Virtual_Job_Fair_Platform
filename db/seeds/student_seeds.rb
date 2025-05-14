# Student Seed Data

# First, let's clear any existing test students to avoid duplicates
User.where('email LIKE ?', 'student%@nu.edu.pk').destroy_all

# Student data
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
  # Skip validation for domain temporarily
  User.class_eval do
    def validate_email_domain
      # Skip validation temporarily
    end
  end

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

puts "10 Student users with profiles seeded successfully!"
