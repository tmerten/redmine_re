class AddReBuildingBlocksInheritingNumbers < ActiveRecord::Migration
 
  def self.up
    add_column :re_building_blocks, :number_format, :string
    add_column :re_building_blocks, :minimal_value, :decimal, :precision => 20, :scale => 10
    add_column :re_building_blocks, :maximal_value, :decimal, :precision => 20, :scale => 10
    add_column :re_building_blocks, :slider, :boolean
    add_column :re_building_blocks, :number_of_digits, :integer
  end

  def self.down
    remove_column :re_building_blocks, :number_format
    remove_column :re_building_blocks, :minimal_value
    remove_column :re_building_blocks, :maximal_value
    remove_column :re_building_blocks, :slider
    remove_column :re_building_blocks, :number_of_digits
  end
end
