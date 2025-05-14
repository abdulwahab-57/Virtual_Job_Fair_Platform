# Extended Student Seed Data with diverse profiles

# First, let's clear any existing test students to avoid duplicates
User.where('email LIKE ?', 'student%@nu.edu.pk').destroy_all

# Sample data lists for randomization
skills_categories = [
  {
    title: "Programming Languages",
    skills: [
      "JavaScript", "Python", "Java", "C++", "Ruby", "PHP", "C#", "Swift",
      "TypeScript", "Go", "Kotlin", "Rust", "Scala", "Perl", "R"
    ]
  },
  {
    title: "Web Development",
    skills: [
      "HTML", "CSS", "React", "Angular", "Vue.js", "Node.js", "Express", "Django",
      "Flask", "Ruby on Rails", "jQuery", "Bootstrap", "Tailwind CSS", "Next.js",
      "GraphQL", "REST API"
    ]
  },
  {
    title: "Database Technologies",
    skills: [
      "SQL", "MongoDB", "PostgreSQL", "MySQL", "SQLite", "Redis", "Firebase",
      "Oracle", "Microsoft SQL Server", "Cassandra", "DynamoDB"
    ]
  },
  {
    title: "Data Science & AI",
    skills: [
      "Machine Learning", "Data Analysis", "TensorFlow", "PyTorch", "Pandas",
      "NumPy", "Scikit-learn", "Natural Language Processing", "Computer Vision",
      "Big Data", "Statistical Analysis", "Data Visualization", "Tableau", "Power BI"
    ]
  },
  {
    title: "Design & UI/UX",
    skills: [
      "UI/UX Design", "Figma", "Adobe XD", "Photoshop", "Illustrator",
      "Wireframing", "Prototyping", "User Research", "Usability Testing"
    ]
  },
  {
    title: "DevOps & Tools",
    skills: [
      "Git", "Docker", "Kubernetes", "AWS", "Azure", "Google Cloud", "CI/CD",
      "Jenkins", "GitHub Actions", "Terraform", "Linux", "Bash Scripting"
    ]
  },
  {
    title: "Mobile Development",
    skills: [
      "Android Development", "iOS Development", "React Native", "Flutter",
      "Swift UI", "Kotlin Multiplatform", "Xamarin"
    ]
  },
  {
    title: "Soft Skills",
    skills: [
      "Communication", "Leadership", "Teamwork", "Problem Solving", "Critical Thinking",
      "Time Management", "Project Management", "Adaptability", "Creativity"
    ]
  }
]

activities_list = [
  { title: "Tech Club President", organization: "NUCES Society" },
  { title: "Hackathon Winner", organization: "CodeFest 2024" },
  { title: "Research Assistant", organization: "Computer Science Department" },
  { title: "Teaching Assistant", organization: "NUCES" },
  { title: "Open Source Contributor", organization: "GitHub" },
  { title: "Web Developer Intern", organization: "Tech Solutions Inc." },
  { title: "Data Science Intern", organization: "Analytics Corp." },
  { title: "Software Developer Intern", organization: "Software House" },
  { title: "Student Ambassador", organization: "Microsoft Learn" },
  { title: "Volunteer", organization: "Community Tech Initiative" },
  { title: "Coding Competition Winner", organization: "ACM ICPC" },
  { title: "Workshop Presenter", organization: "Tech Conference 2023" },
  { title: "Project Lead", organization: "Software Engineering Project" },
  { title: "Competitive Programmer", organization: "Google Kickstart" },
  { title: "Summer School Participant", organization: "Harvard CS50" },
  { title: "Freelance Developer", organization: "Upwork" },
  { title: "Dean's List Recipient", organization: "NUCES" },
  { title: "Social Media Manager", organization: "CS Society" },
  { title: "Game Development Lead", organization: "Game Jam 2024" },
  { title: "AI Research Contributor", organization: "Deep Learning Lab" }
]

projects_list = [
  {
    name: "E-commerce Platform",
    description: "Built a full-stack e-commerce website using MERN stack (MongoDB, Express, React, Node.js) with features like user authentication, product search, shopping cart, and payment integration."
  },
  {
    name: "AI-powered Chatbot",
    description: "Developed a conversational AI chatbot using NLP and machine learning to provide customer support. Integrated with messaging platforms and achieved 80% query resolution rate."
  },
  {
    name: "Mobile Fitness App",
    description: "Created a cross-platform fitness application using Flutter for workout tracking, nutrition planning, and progress visualization with cloud data synchronization."
  },
  {
    name: "Data Visualization Dashboard",
    description: "Designed and implemented an interactive dashboard for COVID-19 data analysis using D3.js, React, and Python backend for data processing."
  },
  {
    name: "Inventory Management System",
    description: "Developed a full-stack inventory management system for local businesses using Java Spring Boot and React with barcode scanning and automated order management."
  },
  {
    name: "Smart Home Automation",
    description: "Built an IoT-based home automation system using Raspberry Pi, Arduino, and a mobile app to control household appliances remotely and monitor energy usage."
  },
  {
    name: "Social Media Analytics Tool",
    description: "Created a tool to analyze social media engagement and sentiment using Python, NLP, and data visualization libraries to help businesses improve their online presence."
  },
  {
    name: "Blockchain-based Voting System",
    description: "Implemented a secure, transparent voting system using blockchain technology to ensure vote integrity and prevent fraud."
  },
  {
    name: "Augmented Reality Education App",
    description: "Developed an AR application for interactive learning experiences in science subjects using Unity and AR frameworks for mobile devices."
  },
  {
    name: "Personal Finance Manager",
    description: "Created a web application for personal finance management with expense tracking, budget planning, and financial goal setting features."
  },
  {
    name: "Environmental Monitoring System",
    description: "Built a system using IoT sensors to monitor air quality, temperature, and humidity in urban areas with real-time data visualization."
  },
  {
    name: "Virtual Reality Campus Tour",
    description: "Designed and developed a VR application offering immersive campus tours for prospective students using Unity and VR headsets."
  },
  {
    name: "AI Image Recognition App",
    description: "Created a mobile application that uses deep learning to identify objects, plants, and landmarks from photos taken by users."
  },
  {
    name: "Event Management Platform",
    description: "Developed a web platform for organizing and managing events with features like ticket sales, attendee management, and event analytics."
  },
  {
    name: "Collaborative Code Editor",
    description: "Built a real-time collaborative code editor with syntax highlighting, version control integration, and video chat for remote pair programming."
  }
]

degrees = [
  "BS (Computer Science)",
  "BS (Software Engineering)",
  "BS (Data Science)",
  "BS (Artificial Intelligence)",
  "BS (Cybersecurity)",
  "BS (Information Technology)",
  "BBA (Management Information Systems)"
]

graduation_years = (2023..2027).to_a

locations = [
  "Islamabad", "Lahore", "Karachi", "Faisalabad", "Rawalpindi",
  "Peshawar", "Multan", "Quetta", "Sialkot", "Hyderabad"
]

interests = [
  "Artificial Intelligence", "Web Development", "Mobile App Development",
  "Data Science", "Cloud Computing", "Cybersecurity", "Game Development",
  "Blockchain", "Internet of Things", "Augmented Reality", "Virtual Reality",
  "Quantum Computing", "Robotics", "UI/UX Design", "DevOps", "Open Source",
  "Machine Learning", "Computer Vision", "Natural Language Processing",
  "Competitive Programming", "Ethical Hacking", "Full Stack Development"
]

# Generate 20 students with rich profiles
20.times do |i|
  student_number = i + 11  # Start from student11 since we already have 1-10

  # Skip validation for domain temporarily
  User.class_eval do
    def validate_email_domain
      # Skip validation temporarily
    end
  end

  # Create the student user
  student = User.new(
    full_name: Faker::Name.name,
    email: "student#{student_number}@nu.edu.pk",
    password: "password123",
    password_confirmation: "password123",
    user_type: "student"
  )

  # Create student profile
  student.build_student_profile(
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 25),
    email_personal: "#{Faker::Internet.user_name}@#{Faker::Internet.domain_name}",
    phone_number: "+92300#{Faker::Number.number(digits: 7)}",
    address: "#{Faker::Address.street_address}, #{Faker::Address.city}",
    linkedin_url: "https://www.linkedin.com/in/#{Faker::Internet.username}",
    status: [ "New", "Active", "Alumni" ].sample
  )

  # Skip the confirmation email and directly confirm the user
  student.skip_confirmation!
  student.save!

  # Confirm the student is active
  student.confirm!

  # Add education entries
  student.student_profile.educations.create!(
    institution_name: "National University of Computer and Emerging Sciences, Chiniot-Faisalabad Campus",
    degree: degrees.sample,
    graduation_year: graduation_years.sample
  )

  # Add a second education entry (intermediate/high school)
  student.student_profile.educations.create!(
    institution_name: "#{Faker::Educator.secondary_school}",
    degree: [ "F.Sc - Pre Engineering", "A Levels - Computer Science", "ICS" ].sample,
    graduation_year: graduation_years.sample - 4  # 4 years before university
  )

  # Add projects (2-4 per student)
  project_count = rand(2..4)
  projects_sample = projects_list.sample(project_count)

  projects_sample.each_with_index do |project, index|
    description = index == 0 ? project[:description] : project[:description][0..120]  # First project has full description
    student.student_profile.projects.create!(
      project_name: project[:name],
      description: description
    )
  end

  # Add skills (2-4 different categories per student)
  categories_sample = skills_categories.sample(rand(2..4))

  categories_sample.each do |category|
    # For each category, pick 3-6 skills
    category_skills = category[:skills].sample(rand(3..6)).join(", ")

    student.student_profile.skills.create!(
      title: category[:title],
      skill_list: category_skills
    )
  end

  # Add activities & honors (1-3 per student)
  activity_count = rand(1..3)
  activities_sample = activities_list.sample(activity_count)

  activities_sample.each do |activity|
    student.student_profile.activities_honors.create!(
      title: activity[:title],
      organization: activity[:organization]
    )
  end

  # Add location preferences (1-3 per student)
  location_count = rand(1..3)
  locations_sample = locations.sample(location_count)

  locations_sample.each do |location|
    student.student_profile.location_preferences.create!(
      location: location
    )
  end

  # Add interests
  interest_count = rand(3..6)
  interests_sample = interests.sample(interest_count).join(", ")

  student.student_profile.interests.create!(
    interest_list: interests_sample
  )
end

puts "20 additional student profiles with comprehensive data seeded successfully!"
