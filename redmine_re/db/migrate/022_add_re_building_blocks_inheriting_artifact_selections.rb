class AddReBuildingBlocksInheritingArtifactSelections < ActiveRecord::Migration
  
  def self.up
    add_column :re_building_blocks, "referred_artifact_types", :string 
    add_column :re_building_blocks, "referred_relationship_types", :string 
    add_column :re_building_blocks, "embedding_type", :string
    add_column :re_building_blocks, "selected_attributes", :string 
    add_column :re_building_blocks, "indicate_changes", :boolean, :default => false
  end

  def self.down
    remove_column :re_building_blocks, "referred_artifact_types"
    remove_column :re_building_blocks, "referred_relationship_types"
    remove_column :re_building_blocks, "embedding_type"
    remove_column :re_building_blocks, "selected_attributes"
    remove_column :re_building_blocks, "indicate_changes"
  end
end
