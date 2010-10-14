class AddCommentToVersioning < ActiveRecord::Migration
    def self.up
       # Kommentar zu einer versioierung ( grund der versionierung / action )
        add_column :re_subtask_versions, "action", :string
        add_column :re_task_versions,    "action", :string
    end

    def self.down
        remove_column :re_subtask_versions, "action"
        remove_column :re_task_versions,    "action"
    end
end
