class ReAttachment < ActiveRecord::Base
end

class ReconfigurePluginAfterRemovingReAttachments < ActiveRecord::Migration

  def self.up
    # Remove re_attachments from re_settings
    attachment_setting = ReSetting.find_by_name("re_attachment")
    unless attachment_setting.nil?
      attachment_setting.destroy
    end
    
    # Remove Setting from array
    ReSetting.find_all_by_name("artifact_order").each do |artifact_order_setting|
      stored_settings = ReSetting.get_serialized("artifact_order", artifact_order_setting.project_id)
      stored_settings.delete("re_attachment")
      ReSetting.set_serialized("artifact_order", artifact_order_setting.project_id, stored_settings)
    end

  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "There is no down Migration for configaration of Attachments. Open Configuration page and click on save to make Attachments work!" 
  end

end