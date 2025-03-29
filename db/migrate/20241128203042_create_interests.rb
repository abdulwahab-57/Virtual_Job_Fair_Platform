class CreateInterests < ActiveRecord::Migration[7.2]
  def change
    create_table :interests do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.text :interest_list, limit: 80
      t.timestamps
    end
  end
end
