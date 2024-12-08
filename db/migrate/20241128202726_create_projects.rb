class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :project_name, limit: 100
      t.text :description
      t.timestamps
    end
  end
end
