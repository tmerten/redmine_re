class ReAttachment < ActiveRecord::Base
  
end

class MigrateReAttachments < ActiveRecord::Migration
  
  def self.up
    
    # Grab all attachments into an array
    #attachment_list[]
    #ReAttachment.each do |a|
    #  attachment_list << a
    #end
    
    # Now we need to Create a Requrement artifact for each attachmen, that contains
    # the attachment of the ReAttachment
    
    
    # At last, we can drop the re_attachments table
    #drop_table :re_attachments
  end
  
  def self.down
    raise ActiveRecord::IrreversibleMigration, "There is no down Migration for Attachments. Attachment Artifacts are not recovered!"
  end
  
end