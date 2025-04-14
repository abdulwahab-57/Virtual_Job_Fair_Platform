class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :message_type
      t.text :message_content
      t.datetime :sent_at
      t.integer :status

      t.timestamps
    end
  end
end
