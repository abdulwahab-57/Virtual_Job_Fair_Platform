class CreateEducations < ActiveRecord::Migration[7.2]
  def change
    create_table :educations do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :institution_name, limit: 100
      t.string :degree_title, limit: 100
      t.string :field_of_study, limit: 100
      t.integer :graduation_year
      t.timestamps
    end
  end
end
