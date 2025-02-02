class CreateCareerOfficerProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :career_officer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :designation
      t.text :introduction
      t.text :education
      t.string :office_location
      t.string :phone_number
      t.string :banner_image
      t.timestamps
    end
  end
end
