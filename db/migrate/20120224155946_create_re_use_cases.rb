class CreateReUseCases < ActiveRecord::Migration
  def self.up
    create_table :re_use_cases do |t|
      t.column :trigger, :text
      t.column :precondition, :text
      t.column :postcondition, :text
      t.column :goal_level, :int
    end
  end

  def self.down
    drop_table :re_use_cases
  end
end
