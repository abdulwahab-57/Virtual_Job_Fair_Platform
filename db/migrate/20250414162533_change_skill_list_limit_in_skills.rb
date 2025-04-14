class ChangeSkillListLimitInSkills < ActiveRecord::Migration[7.2]
  def change
    change_column :skills, :skill_list, :text, limit: 185
  end
end
