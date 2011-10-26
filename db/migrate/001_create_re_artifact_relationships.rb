class CreateReArtifactRelationships < ActiveRecord::Migration
  def self.up
    create_table :re_artifact_relationships do |t|
      t.column :source_id, :integer
      t.column :sink_id, :integer
      t.column :relation_type, :integer
      t.column :position, :integer
      t.column :directed, :boolean
    end
  end

  def self.down
    drop_table :re_artifact_relationships
  end
end
