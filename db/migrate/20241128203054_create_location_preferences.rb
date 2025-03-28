class CreateLocationPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :location_preferences do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :location, limit: 20
      t.timestamps
    end
  end
end
