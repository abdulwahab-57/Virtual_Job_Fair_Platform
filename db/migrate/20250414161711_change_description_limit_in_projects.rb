class ChangeDescriptionLimitInProjects < ActiveRecord::Migration[7.2]
  def change
    change_column :projects, :description, :text, limit: 450
  end
end
