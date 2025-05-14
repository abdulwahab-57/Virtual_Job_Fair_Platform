namespace :db do
  desc "Seed student data only"
  task seed_students: :environment do
    load Rails.root.join("db/seeds/student_seeds.rb")
  end
end
