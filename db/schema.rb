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

ActiveRecord::Schema[7.2].define(version: 2024_12_08_172607) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "user_role", ["student", "recruiter", "career_officer"]

  create_table "career_offices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "institution_name"
    t.string "office_location"
    t.text "introduction"
    t.text "education"
    t.string "banner_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_career_offices_on_user_id"
  end

  create_table "recruiters", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "company_name"
    t.string "industry"
    t.string "office_location"
    t.integer "employee_count"
    t.string "company_website"
    t.string "company_logo_url"
    t.string "banner_image_url"
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recruiters_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "roll_number"
    t.string "graduation_year"
    t.string "student_profile_id"
    t.date "date_of_birth"
    t.string "email_personal"
    t.text "address"
    t.string "linkedin_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_personal"], name: "index_students_on_email_personal", unique: true
    t.index ["roll_number"], name: "index_students_on_roll_number", unique: true
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "phone_number"
    t.string "full_name"
    t.string "user_type"
    t.string "profile_picture_url"
    t.string "profile_type"
    t.bigint "profile_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["profile_type", "profile_id"], name: "index_users_on_profile"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "career_offices", "users"
  add_foreign_key "recruiters", "users"
  add_foreign_key "students", "users"
end
