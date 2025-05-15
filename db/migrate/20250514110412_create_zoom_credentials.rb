class CreateZoomCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :zoom_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
