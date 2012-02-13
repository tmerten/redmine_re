class AddReBuildingBlocksInheritingFiles < ActiveRecord::Migration

  def self.up
    add_column :re_building_blocks, "allowed_filetypes", :string 
    add_column :re_building_blocks, "inline_view_allowed", :integer
  end

  def self.down
    remove_column :re_building_blocks, "allowed_filetypes", :string 
    remove_column :re_building_blocks, "inline_view_allowed", :integer
  end
  
end
