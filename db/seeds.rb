# # This file should ensure the existence of records required to run the application in every environment (production,
# # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Example:
# #
# #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
# #     MovieGenre.find_or_create_by!(name: genre_name)
# #   end
# # db/seeds.rb
# #
# # Ensure existing records are cleared to avoid duplicates
User.destroy_all
# # StudentProfile.destroy_all

# # Create three student users with associated student profiles
# students_data = [
#   {
#     full_name: "Emma Johnson",
#     email: "emma.johnson@example.com",
#     profile_picture_url: "https://example.com/emma_profile.jpg",
#     student_profile: {
#       date_of_birth: Date.new(2000, 5, 15),
#       email_personal: "emma.personal@gmail.com",
#       phone_number: "+1-555-123-4567",
#       address: "123 Scholar Lane, University City, CA 90210",
#       linkedin_url: "https://linkedin.com/in/emmajohnson",
#       educations: [
#         {
#           institution_name: "Stanford University",
#           degree_title: "Bachelor of Science",
#           field_of_study: "Computer Science",
#           graduation_year: 2022
#         },
#         {
#           institution_name: "Massachusetts Institute of Technology",
#           degree_title: "Master of Science",
#           field_of_study: "Artificial Intelligence",
#           graduation_year: 2025
#         }
#       ],
#       projects: [
#         {
#           project_name: "Machine Learning Sentiment Analyzer",
#           description: "Developed an AI-powered sentiment analysis tool using Python and TensorFlow"
#         },
#         {
#           project_name: "E-Commerce Website",
#           description: "Created a full-stack e-commerce platform using Ruby on Rails and React"
#         },
#         {
#           project_name: "IoT Smart Home System",
#           description: "Designed a smart home automation system integrating IoT sensors and Alexa"
#         },
#         {
#           project_name: "Blockchain Voting System",
#           description: "Built a decentralized voting system using Ethereum and Solidity"
#         },
#         {
#           project_name: "Personal Portfolio Website",
#           description: "Developed a responsive personal portfolio site with HTML, CSS, and JavaScript"
#         }
#       ],
#       skills: [
#         {
#           title: "Technical Skills",
#           skill_list: "Python, Machine Learning, TensorFlow, Data Analysis"
#         },
#         {
#           title: "Soft Skills",
#           skill_list: "Leadership, Teamwork, Public Speaking"
#         }
#       ],
#       activities_honors: [
#         {
#           title: "AI Research Assistant",
#           organization: "Stanford AI Lab"
#         },
#         {
#           title: "Hackathon Winner",
#           organization: "MIT Hackathon 2023"
#         },
#         {
#           title: "Dean's List",
#           organization: "Stanford University"
#         }
#       ],
#       interests: [
#         {
#           interest_list: "Artificial Intelligence, Data Science, Robotics"
#         }
#       ],
#       location_preferences: [
#         {
#           location: "San Francisco",
#           preference_order: 1
#         },
#         {
#           location: "Seattle",
#           preference_order: 2
#         },
#         {
#           location: "New York City",
#           preference_order: 3
#         }
#       ]
#     }
#   },
#   {
#     full_name: "Liam Rodriguez",
#     email: "liam.rodriguez@example.com",
#     profile_picture_url: "https://example.com/liam_profile.jpg",
#     student_profile: {
#       date_of_birth: Date.new(1999, 8, 22),
#       email_personal: "liam.personal@gmail.com",
#       phone_number: "+1-555-987-6543",
#       address: "456 Innovation Drive, Tech City, NY 10001",
#       linkedin_url: "https://linkedin.com/in/liamrodriguez",
#       educations: [
#         {
#           institution_name: "MIT",
#           degree_title: "Bachelor of Engineering",
#           field_of_study: "Electrical Engineering and Computer Science",
#           graduation_year: 2021
#         },
#         {
#           institution_name: "University of Cambridge",
#           degree_title: "Master of Philosophy",
#           field_of_study: "Data Science",
#           graduation_year: 2024
#         }
#       ],
#       projects: [
#         {
#           project_name: "Stock Price Predictor",
#           description: "Implemented a stock prediction system using LSTM neural networks"
#         },
#         {
#           project_name: "Social Media Sentiment Tracker",
#           description: "Analyzed trends on social media platforms to determine public sentiment on global issues"
#         },
#         {
#           project_name: "Travel Planner App",
#           description: "Created an app to optimize travel plans using AI-based recommendation systems"
#         },
#         {
#           project_name: "E-Library System",
#           description: "Developed an e-library management system using Django and PostgreSQL"
#         },
#         {
#           project_name: "Fitness Tracker Dashboard",
#           description: "Built a dashboard to track fitness goals using React and Node.js"
#         }
#       ],
#       skills: [
#         {
#           title: "Programming Languages",
#           skill_list: "Java, JavaScript, Python, R"
#         },
#         {
#           title: "Data Analysis Tools",
#           skill_list: "Tableau, Power BI, Excel"
#         }
#       ],
#       activities_honors: [
#         {
#           title: "Best Paper Award",
#           organization: "Cambridge Data Science Conference 2023"
#         },
#         {
#           title: "Research Assistant",
#           organization: "Harvard Economics Lab"
#         },
#         {
#           title: "Volunteer",
#           organization: "UNICEF Summer Program"
#         }
#       ],
#       interests: [
#         {
#           interest_list: "Internet of Things, Smart Technologies, Sustainable Engineering"
#         }
#       ],
#       location_preferences: [
#         {
#           location: "Boston",
#           preference_order: 1
#         },
#         {
#           location: "Los Angeles",
#           preference_order: 2
#         },
#         {
#           location: "Chicago",
#           preference_order: 3
#         }
#       ]
#     }
#   },
#   {
#     full_name: "Sophia Chen",
#     email: "sophia.chen@example.com",
#     profile_picture_url: "https://example.com/sophia_profile.jpg",
#     student_profile: {
#       date_of_birth: Date.new(2001, 3, 10),
#       email_personal: "sophia.personal@gmail.com",
#       phone_number: "+1-555-246-8101",
#       address: "789 Innovation Street, Tech Hub, WA 98101",
#       linkedin_url: "https://linkedin.com/in/sophiachen",
#       educations: [
#         {
#           institution_name: "University of California, Berkeley",
#           degree_title: "Bachelor of Engineering",
#           field_of_study: "Electrical Engineering",
#           graduation_year: 2020
#         },
#         {
#           institution_name: "Carnegie Mellon University",
#           degree_title: "Master of Science",
#           field_of_study: "Robotics",
#           graduation_year: 2023
#         }
#       ],
#       projects: [
#         {
#           project_name: "Autonomous Drone Navigation",
#           description: "Developed an AI system for drone navigation using computer vision"
#         },
#         {
#           project_name: "Smart Traffic Control",
#           description: "Designed a traffic management system using IoT and machine learning"
#         },
#         {
#           project_name: "Weather Prediction Model",
#           description: "Built a predictive weather model using historical climate data"
#         },
#         {
#           project_name: "Speech Recognition System",
#           description: "Implemented a voice assistant using natural language processing"
#         },
#         {
#           project_name: "Game Development with Unity",
#           description: "Created a 3D multiplayer game using Unity and C#"
#         }
#       ],
#       skills: [
#         {
#           title: "Technical Skills",
#           skill_list: "R, Python, Data Visualization, Tableau, Statistical Analysis"
#         },
#         {
#           title: "Programming Frameworks",
#           skill_list: "TensorFlow, PyTorch, OpenCV"
#         }
#       ],
#       activities_honors: [
#         {
#           title: "Robotics Club President",
#           organization: "UC Berkeley"
#         },
#         {
#           title: "Outstanding Graduate Award",
#           organization: "Carnegie Mellon University"
#         },
#         {
#           title: "Top Innovator",
#           organization: "TechCrunch Robotics Summit 2023"
#         }
#       ],
#       interests: [
#         {
#           interest_list: "Public Health Analytics, Social Impact Technology, Data Visualization"
#         }
#       ],
#       location_preferences: [
#         {
#           location: "Austin",
#           preference_order: 1
#         },
#         {
#           location: "San Diego",
#           preference_order: 2
#         },
#         {
#           location: "Denver",
#           preference_order: 3
#         }
#       ]
#     }
#   }
# ]

# # Create users with associated student profiles
# students_data.each do |student_data|
#   user = User.create!(
#     full_name: student_data[:full_name],
#     email: student_data[:email],
#     role: :student,
#     profile_picture_url: student_data[:profile_picture_url]
#   )

#   student_profile = user.create_student_profile!(
#     date_of_birth: student_data[:student_profile][:date_of_birth],
#     email_personal: student_data[:student_profile][:email_personal],
#     phone_number: student_data[:student_profile][:phone_number],
#     address: student_data[:student_profile][:address],
#     linkedin_url: student_data[:student_profile][:linkedin_url]
#   )

#   # Create associated records
#   student_data[:student_profile][:educations].each do |education_data|
#     student_profile.educations.create!(education_data)
#   end

#   student_data[:student_profile][:projects].each do |project_data|
#     student_profile.projects.create!(project_data)
#   end

#   student_data[:student_profile][:skills].each do |skill_data|
#     student_profile.skills.create!(skill_data)
#   end

#   student_data[:student_profile][:activities_honors].each do |activity_data|
#     student_profile.activities_honors.create!(activity_data)
#   end

#   student_data[:student_profile][:interests].each do |interest_data|
#     student_profile.interests.create!(interest_data)
#   end

#   student_data[:student_profile][:location_preferences].each do |preference_data|
#     student_profile.location_preferences.create!(preference_data)
#   end
# end

# puts "Created 3 student users with complete profiles!"

# # Create three recruiter users with associated recruiter profiles
# recruiters_data=[
#     {
#       full_name: "Emily Rodriguez",
#       email: "emily.rodriguez@techtalent.com",
#       profile_picture_url: "https://randomuser.me/api/portraits/women/42.jpg",
#       recruiter_profile: {
#         company_name: "TechTalent Solutions",
#         industry: "Information Technology",
#         about_company: "TechTalent Solutions is a leading tech recruitment agency specializing in placing top tech talent at innovative companies.",
#         office_location: "San Francisco, CA",
#         company_email: "info@techsolutions.com",
#         company_website: "https://www.techtalentsolutions.com",
#         employee_count: "1-50",
#         company_logo: "https://randomuser.me/api/portraits/lego/1.jpg",
#         company_banner_image: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d"
#       }
#     },
#     {
#       full_name: "Michael Chang",
#       email: "michael.chang@globalrecruiters.net",
#       profile_picture_url: "https://randomuser.me/api/portraits/men/35.jpg",
#       recruiter_profile: {
#         company_name: "Global Talent Partners",
#         industry: "Finance and Consulting",
#         about_company: "Global Talent Partners is a premier executive search firm specializing in finance and consulting roles.",
#         office_location: "New York, NY",
#         company_email: "contact@globaltalentpartners.net",
#         company_website: "https://www.globaltalentpartners.net",
#         employee_count: "51-200",
#         company_logo: "https://randomuser.me/api/portraits/lego/5.jpg",
#         company_banner_image: "https://images.unsplash.com/photo-1517245386807-bb43f5d29934"
#       }
#     },
#     {
#       full_name: "Sophia Ahmed",
#       email: "sophia.ahmed@innovatehr.com",
#       profile_picture_url: "https://randomuser.me/api/portraits/women/79.jpg",
#       recruiter_profile: {
#         company_name: "Innovate HR Consulting",
#         industry: "Healthcare Technology",
#         about_company: "Innovate HR Consulting is a healthcare technology staffing agency that connects top talent with leading healthcare organizations.",
#         office_location: "Boston, MA",
#         company_email: "contact@innovatehrconsulting.com",
#         company_website: "https://www.innovatehrconsulting.com",
#         employee_count: "501-1000",
#         company_logo: "https://randomuser.me/api/portraits/lego/8.jpg",
#         company_banner_image: "https://images.unsplash.com/photo-1581291518857-4e27b48ff24e"
#       }
#     }
# ]

# # Create users with associated recruiter profiles
# recruiters_data.each do |recruiter_data|
#   user = User.create!(
#     full_name: recruiter_data[:full_name],
#     email: recruiter_data[:email],
#     role: :recruiter,
#     profile_picture_url: recruiter_data[:profile_picture_url]
#   )

#   user.create_recruiter_profile!(
#     company_name: recruiter_data[:recruiter_profile][:company_name],
#     industry: recruiter_data[:recruiter_profile][:industry],
#     about_company: recruiter_data[:recruiter_profile][:about_company],
#     office_location: recruiter_data[:recruiter_profile][:office_location],
#     company_email: recruiter_data[:recruiter_profile][:company_email],
#     company_website: recruiter_data[:recruiter_profile][:company_website],
#     employee_count: recruiter_data[:recruiter_profile][:employee_count],
#     company_logo: recruiter_data[:recruiter_profile][:company_logo],
#     company_banner_image: recruiter_data[:recruiter_profile][:company_banner_image]
#   )
# end

# puts "Created 3 recruiter users with complete profiles!"

# # Create three career_officer users with associated career_officer profiles
# career_officers_data = [
#   {
#     full_name: "Elizabeth Thompson",
#     email: "elizabeth.thompson@careerguidance.org",
#     profile_picture_url: "https://randomuser.me/api/portraits/women/64.jpg",
#     career_officer_profile: {
#       designation: "Senior Career Development Specialist",
#       introduction: "Dedicated career counselor with over 12 years of experience helping professionals navigate their career paths and achieve their personal and professional goals.",
#       education: "Master of Arts in Career Counseling, Northwestern University",
#       office_location: "Chicago, IL",
#       phone_number: "+1-555-234-5678",
#       banner_image: "https://images.unsplash.com/photo-1552664730-d307ca884978"
#     }
#   },
#   {
#     full_name: "Marcus Wong",
#     email: "marcus.wong@talentdevelopment.com",
#     profile_picture_url: "https://randomuser.me/api/portraits/men/22.jpg",
#     career_officer_profile: {
#       designation: "Career Transition Advisor",
#       introduction: "Passionate about empowering professionals to discover their true potential and successfully navigate career transformations across various industries.",
#       education: "Bachelor of Science in Industrial Psychology, Stanford University",
#       office_location: "San Jose, CA",
#       phone_number: "+1-555-789-1234",
#       banner_image: "https://images.unsplash.com/photo-1551434678-e076c223a692"
#     }
#   },
#   {
#     full_name: "Olivia Martinez",
#     email: "olivia.martinez@professionalpath.net",
#     profile_picture_url: "https://randomuser.me/api/portraits/women/33.jpg",
#     career_officer_profile: {
#       designation: "Global Career Strategy Consultant",
#       introduction: "Strategic career development expert with extensive experience in talent management, professional coaching, and organizational development.",
#       education: "PhD in Organizational Psychology, University of Texas",
#       office_location: "Austin, TX",
#       phone_number: "+1-555-456-7890",
#       banner_image: "https://images.unsplash.com/photo-1573496359107-1da7447bce4f"
#     }
#   }
# ]

# # Create users with associated career_officer profiles
# career_officers_data.each do |career_officer_data|
#   user = User.create!(
#     full_name: career_officer_data[:full_name],
#     email: career_officer_data[:email],
#     role: :career_officer,
#     profile_picture_url: career_officer_data[:profile_picture_url]
#   )

#   user.create_career_officer_profile!(
#     designation: career_officer_data[:career_officer_profile][:designation],
#     introduction: career_officer_data[:career_officer_profile][:introduction],
#     education: career_officer_data[:career_officer_profile][:education],
#     office_location: career_officer_data[:career_officer_profile][:office_location],
#     phone_number: career_officer_data[:career_officer_profile][:phone_number],
#     banner_image: career_officer_data[:career_officer_profile][:banner_image]
#   )
# end

# puts "Created 3 career_officer users with complete profiles!"

# Creating a Career Officer User with an associated profile
User.create!(
  full_name: "John Doe",
  email: "johndoe@cfd.nu.edu.pk",
  password: "SecurePass123",
  password_confirmation: "SecurePass123",
  user_type: "career_officer",
  career_officer_profile_attributes: {
    designation: "Career Advisor"
  }
)

puts "Career Officer user with profile seeded successfully!"
