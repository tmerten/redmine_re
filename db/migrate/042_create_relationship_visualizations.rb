class CreateRelationshipVisualizations < ActiveRecord::Migration
  def self.up
    create_table :re_relationship_visualizations do |t|
      t.column :user_id, :integer
      t.column :project_id, :integer
      t.column :artefakt_id, :integer
      t.column :visualization_typ, :string

      t.column :re_attachment, :integer, :default => 1
      t.column :re_goal, :integer, :default => 1
      t.column :re_processword, :integer, :default => 1
      t.column :re_rationale, :integer, :default => 1
      t.column :re_requirement, :integer, :default => 1
      t.column :re_scenario, :integer, :default => 1
      t.column :re_section, :integer, :default => 1
      t.column :re_task, :integer, :default => 1
      t.column :re_user_profile, :integer, :default => 1
      t.column :re_use_case, :integer, :default => 1
      t.column :re_vision, :integer, :default => 1
      t.column :re_workarea, :integer, :default => 1
      
      t.column :dependency, :integer, :default => 1
      t.column :conflict, :integer, :default => 1
      t.column :rationale, :integer, :default => 1
      t.column :refinement, :integer, :default => 1
      t.column :part_of, :interger, :default => 1
      t.column :parentchild, :integer, :default => 1
      t.column :primary_actor, :integer, :default => 1
      t.column :actors, :integer, :default => 1
      t.column :diagram, :integer, :default => 1
      
      t.column :issue, :integer, :default => 1
      
      t.column :max_deep, :integer, :default => 0
      
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :created_by, :integer, :default => 0
      t.column :updated_by, :integer, :default => 0
      end
  end

  def self.down
   drop_table :re_relationship_visualizations
  end
end
