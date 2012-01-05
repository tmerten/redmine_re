class CreateReBbDataLinks < ActiveRecord::Migration
  def self.up
    create_table :re_bb_data_links do |t|

      t.column :description, :string
      t.column :url, :string
      t.column :re_bb_link_id, :integer
      t.column :re_artifact_properties_id, :integer

    end
  end

  def self.down
    drop_table :re_bb_data_links
  end
end
