# This file creates seed data for 10 students with confirmation skipped

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

students.each do |student_data|
  # Remove any existing user with this email to prevent duplicates
  existing_user = User.find_by(email: student_data[:email])
  existing_user&.destroy

  # Create student user with direct SQL to bypass association validations
  ActiveRecord::Base.connection.execute(<<~SQL)
    INSERT INTO users#{' '}
    (full_name, email, encrypted_password, user_type, confirmed_at, created_at, updated_at)#{' '}
    VALUES#{' '}
    (
      '#{student_data[:name]}',#{' '}
      '#{student_data[:email]}',#{' '}
      '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ/A5B6C7D8E9F0G1H2I3J4K5L6M7N',#{' '}
      'student',
      '#{Time.now.utc.to_s(:db)}',
      '#{Time.now.utc.to_s(:db)}',
      '#{Time.now.utc.to_s(:db)}'
    )
  SQL

  # Get the user ID we just created
  user = User.find_by(email: student_data[:email])

  if user
    # Create student profile with direct SQL
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO student_profiles
      (user_id, email_personal, phone_number, created_at, updated_at)
      VALUES
      (
        #{user.id},
        'personal_#{student_data[:email].gsub('@cfd.nu.edu.pk', '@gmail.com')}',
        '+923001234#{rand(100..999)}',
        '#{Time.now.utc.to_s(:db)}',
        '#{Time.now.utc.to_s(:db)}'
      )
    SQL

    puts "Created student: #{student_data[:name]} (#{student_data[:email]})"
  else
    puts "Failed to create student: #{student_data[:name]}"
  end
end

puts "Successfully created student accounts with confirmation skipped"
