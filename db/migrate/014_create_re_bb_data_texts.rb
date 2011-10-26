class CreateReBbDataTexts < ActiveRecord::Migration
  def self.up
    create_table :re_bb_data_texts do |t|

      t.column :value, :string
      t.column :re_bb_text_id, :integer
      t.column :re_artifact_properties_id, :integer

    end
  end

  def self.down
    drop_table :re_bb_data_texts
  end
end
