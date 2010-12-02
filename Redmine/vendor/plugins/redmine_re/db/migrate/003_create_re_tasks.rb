class CreateReTasks < ActiveRecord::Migration
  def self.up
    add_column :re_subtasks, :type, :string
  end

  def self.down
    remove_column :re_subtasks, :type
  end
end
