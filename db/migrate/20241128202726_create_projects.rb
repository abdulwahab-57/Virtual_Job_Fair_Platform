class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :project_name, limit: 80
      t.text :description, limit: 200
      t.timestamps
    end
  end
end
