class CreateHiringTeamMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :hiring_team_members do |t|
      t.references :recruiter_profile, null: false, foreign_key: true
      t.string :name
      t.string :designation
      t.string :profile_picture_url
      t.timestamps
    end
  end
end
