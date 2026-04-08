class AddMeetingNumberToMeetings < ActiveRecord::Migration[7.2]
  def change
    add_column :meetings, :meeting_number, :string
  end
end
