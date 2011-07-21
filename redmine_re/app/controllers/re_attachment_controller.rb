class ReAttachmentController < RedmineReController
  unloadable


  def edit_hook_after_artifact_initialized params

  end
  
  def edit_hook_validate_before_save(params, valid)
    attachment_hash = params["attachment"] || {}
    attachment_uploaded = @artifact.attach_file(attachment_hash)
    
    attachment_uploaded
  end

  def download_or_show
    @re_attachment = ReAttachment.find(params[:id])
    @re_attachment.attachment = Attachment.find(params[:attachment_id])
    @re_attachment.attachment.increment_download
    
    # images are sent inline
    send_file @re_attachment.attachment.diskfile, 
      :filename => filename_for_content_disposition(@re_attachment.attachment.filename),
      :type => detect_content_type(@re_attachment.attachment),
      :disposition => (@re_attachment.attachment.image? ? 'inline' : 'attachment')
  end
  
  def delete_file
    @re_attachment = ReAttachment.find(params[:id])
    attachment = Attachment.find(params[:attachment_id])
    if attachment.id?
      attachment.destroy
      flash[:notice] = t(:re_attachment_deleted, :name => attachment.filename)
    end
    redirect_to(:controller => :re_attachment, :action => :edit, :id => @re_attachment.id)
  end

  def detect_content_type(attachment)
    content_type = attachment.content_type
    if content_type.blank?
      content_type = Redmine::MimeType.of(attachment.filename)
    end
    content_type.to_s
  end
end