class CreateReRequirements < ActiveRecord::Migration
  def self.up
    create_table :re_requirements do |t|
    end
  end

  def self.down
    drop_table :re_requirements
  end
end
