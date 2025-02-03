class CreateCareerOffices < ActiveRecord::Migration[7.2]
  def change
    create_table :career_offices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :institution_name
      t.string :office_location
      t.text :introduction
      t.text :education
      t.string :banner_image_url
      t.timestamps
    end
  end
end
