class AddParentIdToVersioning < ActiveRecord::Migration
    def self.up
       # Parent id hinzufuegen
        add_column :re_subtask_versions, "parent_artifact_id", :integer, :default => nil
        add_column :re_task_versions, "parent_artifact_id", :integer, :default => nil

       # Zusätzliche attribute um versionstabelle von subtask an der von task anzugleichen
        add_column :re_subtask_versions, "versioned_by_artifact_version", :integer
        add_column :re_subtask_versions, "versioned_by_artifact_id", :integer
    end

    def self.down
        remove_column :re_subtask_versions, "parent_artifact_id"
        remove_column :re_task_versions, "parent_artifact_id"

        remove_column :re_subtask_versions, "versioned_by_artifact_id"
        remove_column :re_subtask_versions, "versioned_by_artifact_version"
    end
end
