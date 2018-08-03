class ReAttachment < ActiveRecord::Base
end

class ReconfigurePluginAfterRemovingReAttachments < ActiveRecord::Migration

  def self.up
  
    # ToDo: Need to be Reimplemented, to be clean with Rails 4
	#
    # Remove re_attachments from re_settings
    #attachment_setting = ReSetting.where(name: "re_attachment")
    #unless attachment_setting.nil?
    #  attachment_setting.destroy
    #end
    # 
    ## Remove Setting from array
    #ReSetting.where(name: "artifact_order").each do |artifact_order_setting|
    #  stored_settings = ReSetting.get_serialized("artifact_order", artifact_order_setting.project_id)
    #  stored_settings.delete("re_attachment")
    #  ReSetting.set_serialized("artifact_order", artifact_order_setting.project_id, stored_settings)
    #end

  end

  def self.down
    say ActiveRecord::IrreversibleMigration, "There is no down Migration for configaration of Attachments. Open Configuration page and click on save to make Attachments work!" 
  end

end