class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :first_name, limit: 50
      t.string :last_name, limit: 50
      t.string :email, limit: 100
      t.column :role, :user_role
      t.string :profile_picture_url
      t.timestamps
    end
  end
end
