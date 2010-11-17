class AddReSubtasksVersioning < ActiveRecord::Migration
    def self.up
        ReSubtask.create_versioned_table

        # Zusätzliche attribute hinzufügen
        add_column :re_subtask_versions, "artifact_name", :string
        add_column :re_subtask_versions, "artifact_description", :string
        add_column :re_subtask_versions, "artifact_priority", :integer, :default => 0
        add_column :re_subtask_versions, "updated_by", :integer
        add_column :re_subtask_versions, "versioned_by_artifact_id", :integer
        add_column :re_subtask_versions, "versioned_by_artifact_version", :integer
        add_column :re_subtask_versions, "parent_artifact_id", :integer, :default => nil
        add_column :re_subtask_versions, "action", :string
    end

    def self.down
       ReSubtask.drop_versioned_table
    end
end
