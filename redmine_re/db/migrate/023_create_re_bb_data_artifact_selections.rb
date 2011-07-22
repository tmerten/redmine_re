class CreateReBbDataArtifactSelections < ActiveRecord::Migration
  def self.up
    create_table :re_bb_data_artifact_selections do |t|

      t.column :re_artifact_relationship_id, :integer
      t.column :re_checked_at, :datetime, :null => false
      t.column :re_bb_artifact_selection_id, :integer
      t.column :re_artifact_properties_id, :integer

    end
  end

  def self.down
    drop_table :re_bb_data_artifact_selections
  end
end
