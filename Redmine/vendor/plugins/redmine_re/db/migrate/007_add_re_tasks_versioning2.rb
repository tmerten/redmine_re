class AddReTasksVersioning2 < ActiveRecord::Migration
    def self.up
        add_column :re_task_versions, "versioned_by_artifact_version", :integer
    end

    def self.down
      remove_column :re_task_versions, "versioned_by_artifact_version"
    end
end
