class AddCommentsCountToReArtifactProperties < ActiveRecord::Migration
  def self.up
    
    add_column :re_artifact_properties, "comments_count", :integer

  end #up

  def self.down
    remove_column :re_artifact_properties, "comments_count"
  end
end

