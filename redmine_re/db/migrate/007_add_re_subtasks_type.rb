class AddReSubtasksType < ActiveRecord::Migration
  def self.up
    add_column :re_subtasks, "sub_type", :integer
  end

  def self.down
    remove_column :re_subtasks, "sub_type", :integer
  end
end
