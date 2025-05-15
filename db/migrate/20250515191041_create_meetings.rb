class CreateMeetings < ActiveRecord::Migration[7.2]
  def change
    create_table :meetings do |t|
      t.string :topic
      t.datetime :start_time
      t.integer :duration
      t.string :host_name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
