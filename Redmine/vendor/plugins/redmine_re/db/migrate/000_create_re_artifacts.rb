class CreateReArtifacts < ActiveRecord::Migration
  def self.up
    create_table :re_artifacts do |t|
      t.column :name, :string
      t.column :created_at, :date
      t.column :updated_at, :date
      t.column :priority, :integer

      t.references :superclass, :polymorphic => true

      t.column :author_id, :integer, :default => 0
      t.column :project_id, :integer, :default => 0      

      t.timestamps
    end
  end

  def self.down
    drop_table :re_artifacts
  end
end
