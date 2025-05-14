#!/usr/bin/env ruby
# This script adds 10 students to the database, skipping confirmation

# Create 10 student users
students = [
  { name: "Ali Ahmed", email: "f219001@cfd.nu.edu.pk" },
  { name: "Sara Khan", email: "f219002@cfd.nu.edu.pk" },
  { name: "Usman Malik", email: "f219003@cfd.nu.edu.pk" },
  { name: "Fatima Zahra", email: "f219004@cfd.nu.edu.pk" },
  { name: "Hassan Raza", email: "f219005@cfd.nu.edu.pk" },
  { name: "Ayesha Tariq", email: "f219006@cfd.nu.edu.pk" },
  { name: "Bilal Hassan", email: "f219007@cfd.nu.edu.pk" },
  { name: "Zainab Ali", email: "f219008@cfd.nu.edu.pk" },
  { name: "Omar Farooq", email: "f219009@cfd.nu.edu.pk" },
  { name: "Maryam Nawaz", email: "f219010@cfd.nu.edu.pk" }
]

puts "Starting student registration..."

# Get the database connection
conn = ActiveRecord::Base.connection

students.each do |student_data|
  # Check for existing user
  existing_user = User.find_by(email: student_data[:email])
  if existing_user
    puts "Deleting existing user: #{existing_user.email}"
    existing_user.destroy
  end

  # Create user directly in the database to bypass validations and callbacks
  begin
    # Generate a password hash
    encrypted_password = User.new(password: "password123").encrypted_password
    now = Time.now.utc.to_s(:db)

    # Insert the user directly
    puts "Creating student: #{student_data[:name]} (#{student_data[:email]})"

    # Insert the user record
    conn.execute(<<~SQL)
      INSERT INTO users
      (
        full_name, email, encrypted_password, user_type, confirmed_at,#{' '}
        created_at, updated_at
      )
      VALUES
      (
        #{conn.quote(student_data[:name])},
        #{conn.quote(student_data[:email])},
        #{conn.quote(encrypted_password)},
        'student',
        #{conn.quote(now)},
        #{conn.quote(now)},
        #{conn.quote(now)}
      )
    SQL

    # Get the user ID
    user_id_result = conn.execute(<<~SQL)
      SELECT id FROM users WHERE email = #{conn.quote(student_data[:email])}
    SQL

    user_id = user_id_result.first["id"]

    # Insert student profile
    if user_id
      personal_email = "personal_#{student_data[:email].gsub('@cfd.nu.edu.pk', '@gmail.com')}"
      phone_number = "+923001234#{rand(100..999)}"

      conn.execute(<<~SQL)
        INSERT INTO student_profiles
        (
          user_id, email_personal, phone_number,
          created_at, updated_at
        )
        VALUES
        (
          #{user_id},
          #{conn.quote(personal_email)},
          #{conn.quote(phone_number)},
          #{conn.quote(now)},
          #{conn.quote(now)}
        )
      SQL

      puts "Successfully created student: #{student_data[:name]}"
    else
      puts "Failed to get user ID for #{student_data[:name]}"
    end
  rescue => e
    puts "Error creating student #{student_data[:name]}: #{e.message}"
  end
end

puts "Student registration completed!"
