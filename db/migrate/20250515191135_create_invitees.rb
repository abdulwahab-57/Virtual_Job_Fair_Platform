class CreateInvitees < ActiveRecord::Migration[7.2]
  def change
    create_table :invitees do |t|
      t.string :email
      t.references :meeting, null: false, foreign_key: true

      t.timestamps
    end
  end
end
