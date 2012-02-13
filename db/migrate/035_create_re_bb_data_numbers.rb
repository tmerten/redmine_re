class CreateReBbDataNumbers < ActiveRecord::Migration
  def self.up
    create_table :re_bb_data_numbers do |t|

      t.column :value, :decimal, :precision  => 20, :scale => 10
      t.column :re_bb_number_id, :integer
      t.column :re_artifact_properties_id, :integer

    end
  end

  def self.down
    drop_table :re_bb_data_numbers
  end
end
