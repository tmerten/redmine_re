class ReAttachment < ActiveRecord::Base
  unloadable
  
  acts_as_re_artifact
  acts_as_attachable :after_remove => :attachment_removed

  belongs_to :attachment


  def attach_file(attachment_hash)
    return false unless self.valid?
    return true  if self.attachment
    
    if attachment_hash.blank?
      self.errors.add_to_base(I18n.t(:re_attachment_no_file_error))
      return false
    end
    success = false

    # set the name of the current ReAttachment as description of the redmine attachment
    #attachment_hash["1"]["description"] = self.name

    # try to attach the file gets a hash with attached and unsaved attached files
    result  = Attachment.attach_files(self, attachment_hash)
    success = check_attaching_result(attachment_hash, result)


    uploaded_attachment = result[:files][0]
    self.attachment = uploaded_attachment if success

    success
  end

  private

  def check_attaching_result(attachment_hash, result)
    attachment_file = attachment_hash["1"]["file"]

    # if attachment in the files hash everything ok and valid
    if result[:unsaved].blank? && !result[:files].blank?
      return true
    # if both hashes empty than the filesize equals 0 (See attachment.tb line 147)
    elsif result[:unsaved].blank? && result[:files].blank?
      if attachment_file.size == 0
        self.errors.add_to_base(I18n.t(:re_attachment_size_greater_zero))
        return false
      end
    # if the attachment is found in the unsaved hash there should be a validation error
    elsif !result[:unsaved].blank? && result[:files].blank?
      if self.unsaved_attachments[0].errors.size > 0
        self.unsaved_attachments[0].errors.each_full{|msg| self.errors.add_to_base(I18n.t(:re_attachment_validation_error, :msg => msg)) }
      end
    end
    return false
  end
end
