class AddReBuildingBlocksInheritingText < ActiveRecord::Migration
  def self.up
    add_column :re_building_blocks, "default_value", :string 
    add_column :re_building_blocks, "min_length", :integer
    add_column :re_building_blocks, "max_length", :integer
  end

  def self.down
    remove_column :re_building_blocks, "default_value"
    remove_column :re_building_blocks, "min_length"
    remove_column :re_building_blocks, "max_length"
  end
end
