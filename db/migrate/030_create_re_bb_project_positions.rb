class CreateReBbProjectPositions < ActiveRecord::Migration
  def self.up
    create_table :re_bb_project_positions do |t|

      t.column :re_building_block_id, :integer

      t.column :project_id, :integer

      t.column :position, :integer

    end
  end

  def self.down
    drop_table :re_bb_project_positions
  end
end
