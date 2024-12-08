class CreateUserRoleEnum < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('student', 'recruiter', 'career_officer');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
