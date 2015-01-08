class CreateReVisualizationConfigs < ActiveRecord::Migration
  def self.up
    
    create_table :re_visualization_configs do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :visualization_type
      t.string :configuration_type
      t.string :configuration_name
      t.string :configuration_value
    end
      
  end

  def self.down
    drop_table :re_visualization_configs
  end
end