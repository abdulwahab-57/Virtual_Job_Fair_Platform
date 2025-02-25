# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_28_203054) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "employee_range", ["1-50", "51-200", "201-500", "501-1000", "1001+"]

  create_table "activities_honors", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.string "title", limit: 100
    t.string "organization", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_profile_id"], name: "index_activities_honors_on_student_profile_id"
  end

  create_table "career_officer_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "designation"
    t.text "introduction"
    t.text "education"
    t.string "office_location"
    t.string "phone_number"
    t.string "banner_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_career_officer_profiles_on_user_id"
  end

  create_table "educations", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.string "institution_name", limit: 100
    t.string "degree_title", limit: 100
    t.string "field_of_study", limit: 100
    t.integer "graduation_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_profile_id"], name: "index_educations_on_student_profile_id"
  end

  create_table "interests", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.text "interest_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_profile_id"], name: "index_interests_on_student_profile_id"
  end

  create_table "location_preferences", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.string "location", limit: 50
    t.integer "preference_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_profile_id"], name: "index_location_preferences_on_student_profile_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.string "project_name", limit: 100
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_profile_id"], name: "index_projects_on_student_profile_id"
  end

  create_table "recruiter_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "company_name"
    t.string "industry"
    t.string "about_company"
    t.string "office_location"
    t.string "company_email"
    t.string "company_website"
    t.enum "employee_count", enum_type: "employee_range"
    t.string "company_logo"
    t.string "company_banner_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recruiter_profiles_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.string "title", limit: 100, null: false
    t.text "skill_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_profile_id"], name: "index_skills_on_student_profile_id"
  end

  create_table "student_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date_of_birth"
    t.string "email_personal", limit: 100
    t.string "phone_number", limit: 20
    t.text "address"
    t.string "linkedin_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_student_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "user_type"
    t.string "profile_picture_url"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities_honors", "student_profiles"
  add_foreign_key "career_officer_profiles", "users"
  add_foreign_key "educations", "student_profiles"
  add_foreign_key "interests", "student_profiles"
  add_foreign_key "location_preferences", "student_profiles"
  add_foreign_key "projects", "student_profiles"
  add_foreign_key "recruiter_profiles", "users"
  add_foreign_key "skills", "student_profiles"
  add_foreign_key "student_profiles", "users"
end
