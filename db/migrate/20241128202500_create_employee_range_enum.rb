class CreateEmployeeRangeEnum < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE TYPE employee_range AS ENUM ('1-50', '51-200', '201-500', '501-1000', '1001+');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE employee_range;
    SQL
  end
end
