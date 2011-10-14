class AddReBuildingBlocksProjectId < ActiveRecord::Migration
  
  def self.up
    add_column :re_building_blocks, "project_id", :integer, :default => 1 
  end

  def self.down
    remove_column :re_building_blocks, "project_id"
  end
end
