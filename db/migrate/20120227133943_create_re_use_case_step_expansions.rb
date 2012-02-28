class CreateReUseCaseStepExpansions < ActiveRecord::Migration
  def self.up
    create_table :re_use_case_step_expansions do |t|
      t.column :re_use_case_step_id, :int
      t.column :re_expansion_type, :int
      t.column :description, :text
      t.column :position, :int
    end
  end

  def self.down
    drop_table :re_use_case_step_expansions
  end
end
