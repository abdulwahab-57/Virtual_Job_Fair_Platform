class AddJoinUrlToMeetings < ActiveRecord::Migration[7.2]
  def change
    add_column :meetings, :join_url, :string
  end
end
