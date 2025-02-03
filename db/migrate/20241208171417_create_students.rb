class CreateStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :students do |t|
      t.references :user, null: false, foreign_key: true
      t.string :roll_number
      t.string :graduation_year
      t.string :student_profile_id
      t.date :date_of_birth
      t.string :email_personal
      t.text :address
      t.string :linkedin_url

      t.timestamps
    end

    # Place add_index after create_table to avoid "relation does not exist" errors
    add_index :students, :roll_number, unique: true
    add_index :students, :email_personal, unique: true
  end
end
