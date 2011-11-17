class RemovePositionFromReBuildingBlocks < ActiveRecord::Migration
  
  def self.up
    remove_column :re_building_blocks, "position"
  end

  def self.down
    add_column :re_building_blocks, "position"
  end
end
