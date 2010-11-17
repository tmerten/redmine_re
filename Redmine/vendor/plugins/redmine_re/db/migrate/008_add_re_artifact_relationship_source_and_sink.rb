class AddReArtifactRelationshipSourceAndSink < ActiveRecord::Migration
  def self.up
    add_column :re_artifact_relationships, "source_id", :integer
    add_column :re_artifact_relationships, "sink_id", :integer
    add_column :re_artifact_relationships, "relation_type", :integer
    add_column :re_artifact_relationships, "position", :integer
  end

  def self.down
    remove_column :re_artifact_relationships, "source_id"
    remove_column :re_artifact_relationships, "sink_id"
    remove_column :re_artifact_relationships, "relation_type"
    remove_column :re_artifact_relationships, "position"
  end
end
