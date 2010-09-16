class AddReSubtasksVersioning2 < ActiveRecord::Migration
    def self.up
       # Zusätzliche attribute hinzufügen Subtasks Version:
        add_column :re_subtask_versions, "artifact_name", :string
        add_column :re_subtask_versions, "artifact_priority", :integer, :default => 0
        add_column :re_subtask_versions, "updated_by", :integer

    end

    def self.down
        remove_column :re_subtask_versions, "artifact_name"
        remove_column :re_subtask_versions, "artifact_priority"
        remove_column :re_subtask_versions, "updated_by"
    end
end
