class CreateReUseCaseSteps < ActiveRecord::Migration
  def self.up
    create_table :re_use_case_steps do |t|
      t.column :re_use_case_id, :int
      t.column :step_type, :int
      t.column :description, :text
      t.column :position, :int
    end
  end

  def self.down
    drop_table :re_use_case_steps
  end
end
