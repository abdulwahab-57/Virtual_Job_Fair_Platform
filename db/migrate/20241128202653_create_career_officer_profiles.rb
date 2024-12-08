class CreateCareerOfficerProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :career_officer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :designation
      t.string :phone
      t.string :phone_extension
      t.string :office_location
      t.text :introduction
      t.text :education
      t.string :banner_image_url
      t.timestamps
    end
  end
end
