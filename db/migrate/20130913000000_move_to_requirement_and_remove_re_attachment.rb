class ReAttachment < ActiveRecord::Base
end

class MoveToRequirementAndRemoveReAttachment < ActiveRecord::Migration

  def self.up
    ReArtifactProperties.find_all_by_artifact_type("ReAttachment").each do |artifact|

      # Find each ReAttachment and
      # change its container_type to ReArtifactProperties and its ID to the artifact id
      attachment = Attachment.find_by_container_id_and_container_type(artifact.artifact_id, "ReAttachment")
      
      unless attachment.nil?
        attachment.container_type = "ReArtifactProperties"
        attachment.container_id = artifact.id
        attachment.save
      end

      # Now we need to change the type of the ReArtifactProperties 
      # to ReRequrement for each ReAttachment
      artifact.artifact_type = "ReRequirement"
      artifact.artifact_id = nil
      artifact.save
    end
    
    # At last, we can drop the re_attachments table
    drop_table :re_attachments
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "There is no down Migration for Attachments. Attachment Artifacts are not recovered!" 
  end

end