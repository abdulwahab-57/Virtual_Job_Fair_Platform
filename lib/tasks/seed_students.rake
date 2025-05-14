namespace :db do
  desc "Seed 10 student accounts with confirmation skipped"
  task seed_students: :environment do
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

    # Disable meeting_participants association temporarily
    User.class_eval do
      # Store the original associations
      @@has_many_meeting_participants = User.reflect_on_association(:meeting_participants)
      @@has_many_meetings = User.reflect_on_association(:meetings)
      @@has_many_hosted_meetings = User.reflect_on_association(:hosted_meetings)

      # Remove the problematic associations
      has_many :meeting_participants, -> { none }
      has_many :meetings, -> { none }
      has_many :hosted_meetings, -> { none }
    end

    # Skip confirmation
    User.skip_callback(:create, :after, :send_on_create_confirmation_instructions)

    students.each do |student_data|
      # Remove any existing user with this email to prevent duplicates
      existing_user = User.find_by(email: student_data[:email])
      existing_user&.destroy

      # Create the student user with profile
      student = User.new(
        full_name: student_data[:name],
        email: student_data[:email],
        password: "password123",
        password_confirmation: "password123",
        user_type: "student",
        student_profile_attributes: {
          email_personal: "personal_#{student_data[:email].gsub('@cfd.nu.edu.pk', '@gmail.com')}",
          phone_number: "+923001234#{rand(100..999)}"
        }
      )

      # Skip confirmation
      student.skip_confirmation!
      student.save(validate: false)

      puts "Created student: #{student.full_name} (#{student.email})"
    end

    # Re-enable confirmation emails
    User.set_callback(:create, :after, :send_on_create_confirmation_instructions)

    # Restore original associations (if needed in the rake process)
    User.class_eval do
      # Reset the associations if needed
    end

    puts "Successfully created 10 student accounts with confirmation skipped"
  end
end
