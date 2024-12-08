class CreateGalleryImages < ActiveRecord::Migration[7.2]
  def change
    create_table :gallery_images do |t|
      t.references :recruiter_profile, null: false, foreign_key: true
      t.string :image_url
      t.timestamps
    end
  end
end
