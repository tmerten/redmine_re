class CreateRealizations < ActiveRecord::Migration
  def self.up
    create_table :realizations do |t|
      t.column :issue_id, :integer
      t.column :re_artifact_properties_id, :integer
    end
  end

  def self.down
    if table_exists?(:realizations)
      drop_table :realizations 
    end
  end
end
