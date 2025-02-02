class CreateRecruiterProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :recruiter_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name
      t.string :industry
      t.string :about_company
      t.string :office_location
      t.string :company_email
      t.string :company_website
      t.column :employee_count, :employee_range
      t.string :company_logo
      t.string :company_banner_image
      t.timestamps
    end
  end
end
