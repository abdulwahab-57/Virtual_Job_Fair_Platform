class CreateUserSearches < ActiveRecord::Migration[7.2]
  def change
    create_table :user_searches do |t|
      t.integer :user_id
      t.string :search_query
      t.datetime :search_date
      t.integer :search_results

      t.timestamps
    end
  end
end
