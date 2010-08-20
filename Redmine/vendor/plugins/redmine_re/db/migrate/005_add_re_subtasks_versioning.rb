class AddReSubtasksVersioning < ActiveRecord::Migration
    def self.up
        ReSubtask.create_versioned_table
    end

    def self.down
       ReSubtask.drop_versioned_table
    end
end
