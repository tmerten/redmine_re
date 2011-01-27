class CreateReSections < ActiveRecord::Migration
  def self.up
    create_table :re_sections do |t|
    end
  end

  def self.down
    drop_table :re_sections
  end
end
