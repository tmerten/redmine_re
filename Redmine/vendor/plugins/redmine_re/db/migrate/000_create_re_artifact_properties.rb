class CreateReArtifactProperties < ActiveRecord::Migration
  def self.up
    create_table :re_artifact_properties do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :priority, :integer
      t.column :responsibles, :string

      t.column :created_at, :date
      t.column :updated_at, :date
      t.column :created_by, :integer, :default => 0
      t.column :updated_by, :integer, :default => 0

      t.references :artifact, :polymorphic => true

      t.column :project_id, :integer, :default => 0      

      t.timestamps
    end
  end

  def self.down
    drop_table :re_artifact_properties
  end
end
