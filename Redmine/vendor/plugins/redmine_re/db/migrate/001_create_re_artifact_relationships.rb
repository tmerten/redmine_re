class CreateReArtifactRelationships < ActiveRecord::Migration
  def self.up
    create_table :re_artifact_relationships do |t|
      t.column :from, :integer
      t.column :to, :integer
      t.column :parent_id, :integer
      t.column :directed, :boolean
    end
  end

  def self.down
    drop_table :re_artifact_relationships
  end
end
