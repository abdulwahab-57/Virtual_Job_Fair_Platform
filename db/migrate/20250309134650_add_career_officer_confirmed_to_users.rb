class AddCareerOfficerConfirmedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :career_officer_confirmed, :boolean
  end
end
