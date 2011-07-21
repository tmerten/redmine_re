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
    @re_attachment.attachment.increment_download

    # images are sent inline
    send_file @re_attachment.attachment.diskfile, :filename => filename_for_content_disposition(@re_attachment.attachment.filename),
                                    :type => Redmine::MimeType.of(@re_attachment.attachment.filename),
                                    :disposition => (@re_attachment.attachment.image? ? 'inline' : 'attachment')
  end

end