class AddReTasksVersioning < ActiveRecord::Migration
    def self.up
        ReTask.create_versioned_table

        # Zusätzliche attribute hinzufügen
        add_column :re_task_versions, "artifact_name", :string
        add_column :re_task_versions, "artifact_description", :string
        add_column :re_task_versions, "artifact_priority", :integer, :default => 0
        add_column :re_task_versions, "updated_by", :integer
        add_column :re_task_versions, "versioned_by_artifact_id", :integer
        add_column :re_task_versions, "versioned_by_artifact_version", :integer
        add_column :re_task_versions, "parent_artifact_id", :integer, :default => nil
        add_column :re_task_versions, "action", :string
    end

    def self.down
       ReTask.drop_versioned_table
    end
end
