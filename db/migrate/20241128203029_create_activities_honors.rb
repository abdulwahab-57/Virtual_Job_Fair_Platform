class CreateActivitiesHonors < ActiveRecord::Migration[7.2]
  def change
    create_table :activities_honors do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :title, limit: 30
      t.string :organization, limit: 30
      t.timestamps
    end
  end
end
