class CreateReSubtasks < ActiveRecord::Migration
  def self.up
    create_table :re_subtasks do |t|
      t.column :solution, :string
    end
  end

  def self.down
    drop_table :re_subtasks
  end
end
