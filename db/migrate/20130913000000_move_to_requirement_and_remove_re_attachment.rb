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
    
    # Now we can drop the old re_attachments table
    drop_table :re_attachments
    
    # Remove re_attachments from re_settings
    attachment_setting = ReSetting.find_by_name("re_attachment")
    unless attachment_setting.nil?
      attachment_setting.destroy
    end

    # Remove Setting from array
    artifact_order = ReSetting.find_by_name("artifact_order")
    unless artifact_order.nil? 
      artifact_order.each do |artifact_order_setting|
        stored_settings = ReSetting.get_serialized("artifact_order", artifact_order_setting.project_id)
        stored_settings.delete(:ReAttachments)
        ReSetting.set_serialized("artifact_order", artifact_order_setting.project_id, stored_settings)
      end
    end

  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "There is no down Migration for Attachments. Attachment Artifacts are not recovered!" 
  end

end