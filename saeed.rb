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

# Generate encrypted password
sample_user = User.new(password: "password123")
encrypted_password = sample_user.encrypted_password

# Process each student
students.each do |student_data|
  # Delete existing user if exists
  existing = User.find_by(email: student_data[:email])
  existing&.destroy

  # Insert directly into the database
  begin
    # Use ActiveRecord's connection to run SQL
    now = Time.now.utc.to_s(:db)

    # Insert user
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO users (
        full_name, email, encrypted_password, user_type,#{' '}
        confirmed_at, created_at, updated_at
      ) VALUES (
        '#{student_data[:name].gsub("'", "''")}',
        '#{student_data[:email].gsub("'", "''")}',
        '#{encrypted_password.gsub("'", "''")}',
        'student',
        '#{now}',
        '#{now}',
        '#{now}'
      )
    SQL

    # Get the user's ID
    result = ActiveRecord::Base.connection.execute(<<~SQL)
      SELECT id FROM users WHERE email = '#{student_data[:email].gsub("'", "''")}'
    SQL

    user_id = result.first['id']
    personal_email = "personal_#{student_data[:email].gsub('@cfd.nu.edu.pk', '@gmail.com')}"
    phone_number = "+923001234#{rand(100..999)}"

    # Insert student profile
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO student_profiles (
        user_id, email_personal, phone_number,#{' '}
        created_at, updated_at
      ) VALUES (
        #{user_id},
        '#{personal_email.gsub("'", "''")}',
        '#{phone_number.gsub("'", "''")}',
        '#{now}',
        '#{now}'
      )
    SQL

    puts "Created student: #{student_data[:name]} (#{student_data[:email]})"
  rescue => e
    puts "Error creating student #{student_data[:name]}: #{e.message}"
  end
end
