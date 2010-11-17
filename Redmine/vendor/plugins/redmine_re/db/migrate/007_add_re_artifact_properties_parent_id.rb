class AddReArtifactPropertiesParentId < ActiveRecord::Migration
  # TODO: Remove me if parent child through relationship works 
  def self.up
    add_column :re_artifact_properties, "parent_artifact_id", :integer
  end

  def self.down
    remove_column :re_artifact_properties, "parent_artifact_id"
  end
end
