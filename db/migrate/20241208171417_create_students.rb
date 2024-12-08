class CreateStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :students do |t|
      t.string :roll_number
      t.date :graduation_year

      t.timestamps
    end
  end
end
