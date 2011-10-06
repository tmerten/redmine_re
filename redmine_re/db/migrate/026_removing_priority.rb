class RemovePriority < ActiveRecord::Migration
  def self.up
    remove_column :re_artifact_properties, "priority", :integer
  end

  def self.down
    add_column :re_artifact_properties, "priority", :integer
  end
end
