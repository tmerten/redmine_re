class CreateReTasks < ActiveRecord::Migration
  def self.up
    create_table :re_tasks do |t|
      t.column :start, :string
      t.column :end, :string
      t.column :frequency, :string
      t.column :difficult, :text
    end
  end

  def self.down
    drop_table :re_tasks
  end
end
