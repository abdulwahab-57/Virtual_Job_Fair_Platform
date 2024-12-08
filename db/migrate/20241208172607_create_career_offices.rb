class CreateCareerOffices < ActiveRecord::Migration[7.2]
  def change
    create_table :career_offices do |t|
      t.string :institution_name
      t.string :department

      t.timestamps
    end
  end
end
