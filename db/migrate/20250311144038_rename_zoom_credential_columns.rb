class RenameZoomCredentialColumns < ActiveRecord::Migration[7.2]
  def change
    # Add new columns
    add_column :zoom_credentials, :encrypted_access_token, :text
    add_column :zoom_credentials, :encrypted_access_token_iv, :text
    add_column :zoom_credentials, :encrypted_refresh_token, :text
    add_column :zoom_credentials, :encrypted_refresh_token_iv, :text

    # Copy data from old columns to new columns if they exist
    if column_exists?(:zoom_credentials, :access_token)
      execute <<-SQL
        UPDATE zoom_credentials#{' '}
        SET encrypted_access_token = access_token,
            encrypted_refresh_token = refresh_token;
      SQL
    end

    # Remove old columns if they exist
    if column_exists?(:zoom_credentials, :access_token)
      remove_column :zoom_credentials, :access_token
      remove_column :zoom_credentials, :refresh_token
    end
  end
end
