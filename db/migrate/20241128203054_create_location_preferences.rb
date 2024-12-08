class CreateLocationPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :location_preferences do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :location, limit: 50
      t.integer :preference_order
      t.timestamps
    end
  end
end
