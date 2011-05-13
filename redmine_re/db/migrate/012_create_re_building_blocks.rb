class CreateReBuildingBlocks < ActiveRecord::Migration
  def self.up
    create_table :re_building_blocks do |t|
      t.column :artifact_type, :string
      t.column :name, :string
      t.column :help, :string
      t.column :mandatory, :boolean
      t.column :for_every_project, :boolean
      t.column :multiple_values, :boolean
      t.column :grouped, :boolean
      t.column :for_condensed_view, :boolean
      t.column :for_search, :boolean
      t.column :arrangable_by_users, :boolean
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :re_building_blocks
  end
end
