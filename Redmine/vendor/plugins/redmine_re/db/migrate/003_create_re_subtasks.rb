class CreateReSubtasks < ActiveRecord::Migration
  def self.up
    create_table :re_subtasks do |t|
      t.column :description, :string
      t.column :solution, :string
      t.column :re_task_id, :integer
    end
  end

  def self.down
    drop_table :re_subtasks
  end
end
