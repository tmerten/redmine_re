class CreateReTasks < ActiveRecord::Migration
  def self.up
    create_table :re_tasks do |t|
    end
  end

  def self.down
    drop_table :re_tasks
  end
end
