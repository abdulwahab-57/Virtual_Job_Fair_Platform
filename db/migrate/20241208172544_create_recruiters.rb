class CreateRecruiters < ActiveRecord::Migration[7.2]
  def change
    create_table :recruiters do |t|
      t.string :company_name
      t.string :designation

      t.timestamps
    end
  end
end
