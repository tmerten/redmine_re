class CreateReVisions < ActiveRecord::Migration
  def self.up
    create_table :re_visions do |t|
    end
  end

  def self.down
    drop_table :re_visions
  end
end
