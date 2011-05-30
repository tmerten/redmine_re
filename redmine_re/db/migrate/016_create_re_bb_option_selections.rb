class CreateReBbOptionSelections < ActiveRecord::Migration
  def self.up
    create_table :re_bb_option_selections do |t|

      t.column :re_bb_selection_id, :integer
      t.column :value, :string

    end
  end

  def self.down
    drop_table :re_bb_option_selections
  end
end
