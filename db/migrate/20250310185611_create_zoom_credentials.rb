class CreateZoomCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :zoom_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.text :encrypted_access_token
      t.text :encrypted_access_token_iv
      t.text :encrypted_refresh_token
      t.text :encrypted_refresh_token_iv
      t.datetime :expires_at

      t.timestamps
    end
  end
end
