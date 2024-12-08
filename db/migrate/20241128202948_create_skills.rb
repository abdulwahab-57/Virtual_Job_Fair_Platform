class CreateSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :skills do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :title, null: false, limit: 100
      t.text :skill_list
      t.timestamps
    end
  end
end
