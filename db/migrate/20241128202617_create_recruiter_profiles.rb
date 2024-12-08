class CreateRecruiterProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :recruiter_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name
      t.string :industry
      t.string :office_location
      t.column :employee_count, :employee_range
      t.string :company_website
      t.string :company_logo_url
      t.string :banner_image_url
      t.timestamps
    end
  end
end
