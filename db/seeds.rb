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

# Creating a Career Officer User with an associated profile
# User.create!(
#   full_name: "Aysha Shafiq",
#   email: "cfd.cso@nu.edu.pk",
#   password: "123456789",
#   password_confirmation: "123456789",
#   user_type: "career_officer",
#   career_officer_profile_attributes: {
#     designation: "Deputy Manager"
#   }
# )


# User.create!(
#   full_name: "Noor Mughal",
#   email: "f223634@cfd.nu.edu.pk",
#   password: "123456789",
#   password_confirmation: "123456789",
#   user_type: "career_officer",
#   career_officer_profile_attributes: {
#     designation: "Career Services Manager"
#   }
# )

# puts "Career Officer users with profile seeded successfully!"
