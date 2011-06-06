class CreateReScenarios < ActiveRecord::Migration
  def self.up
    create_table :re_scenarios do |t|
    end
  end

  def self.down
    drop_table :re_scenarios
  end
end
