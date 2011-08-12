class CreateReProcesswords < ActiveRecord::Migration
  def self.up
    create_table :re_processwords do |t|
      t.column :synonyms, :text
    end
  end

  def self.down
    drop_table :re_processwords
  end
end
