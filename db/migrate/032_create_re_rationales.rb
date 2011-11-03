class CreateReRationales < ActiveRecord::Migration
  def self.up
    create_table :re_rationales do |t|
    end
  end

  def self.down
    drop_table :re_rationales
  end
end
