class CreateReBbDataSelections < ActiveRecord::Migration
  def self.up
    create_table :re_bb_data_selections do |t|

      t.column :re_bb_option_selection_id, :integer
      t.column :re_bb_selection_id, :integer
      t.column :re_artifact_properties_id, :integer

    end
  end

  def self.down
    drop_table :re_bb_data_selections
  end
end
