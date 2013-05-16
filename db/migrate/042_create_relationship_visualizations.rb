class CreateRelationshipVisualizations < ActiveRecord::Migration
  def self.up
    create_table :re_relationship_visualizations do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :artefakt_id
      t.string :visualization_typ

      t.integer :re_attachment, :default => 1
      t.integer :re_goal, :default => 1
      t.integer :re_processword, :default => 1
      t.integer :re_rationale, :default => 1
      t.integer :re_requirement, :default => 1
      t.integer :re_scenario, :default => 1
      t.integer :re_section, :default => 1
      t.integer :re_task, :default => 1
      t.integer :re_user_profile, :default => 1
      t.integer :re_use_case, :default => 1
      t.integer :re_vision, :default => 1
      t.integer :re_workarea, :default => 1
      
      t.integer :dependency, :default => 1
      t.integer :conflict, :default => 1
      t.integer :rationale, :default => 1
      t.integer :refinement, :default => 1
      t.integer :part_of, :default => 1
      t.integer :parentchild, :default => 1
      t.integer :primary_actor, :default => 1
      t.integer :actors, :default => 1
      t.integer :diagram, :default => 1
      
      t.integer :issue, :default => 1
      
      t.integer :max_deep, :default => 0
      
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.integer :created_by, :default => 0
      t.integer :updated_by, :default => 0
      end
  end

  def self.down
   drop_table :re_relationship_visualizations
  end
end
