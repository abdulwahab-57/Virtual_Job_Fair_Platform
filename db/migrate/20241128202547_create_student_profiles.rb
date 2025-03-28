class CreateStudentProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :student_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date_of_birth
      t.string :email_personal, limit: 100
      t.string :phone_number, limit: 13
      t.text :address
      t.string :linkedin_url, limit: 255
      t.string :status, default: "Not Reviewed"
      t.timestamps
    end
  end
end
