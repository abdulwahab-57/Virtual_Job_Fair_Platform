class CreateMeetings < ActiveRecord::Migration[7.2]
  def change
    create_table :meetings do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :zoom_meeting_id
      t.string :zoom_meeting_url
      t.string :zoom_meeting_password
      t.integer :host_id
      t.string :status

      t.timestamps
    end
  end
end
