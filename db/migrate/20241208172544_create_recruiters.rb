class CreateRecruiters < ActiveRecord::Migration[7.2]
  def change
    create_table :recruiters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name
      t.string :industry
      t.string :office_location
      t.integer :employee_count
      t.string :company_website
      t.string :company_logo_url
      t.string :banner_image_url
      t.string :designation

      t.timestamps
    end
  end
end
