class ReAttachmentController < RedmineReController
  unloadable

  def new
    # redirects to edit to be more dry
    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_attachment = ReAttachment.find_by_id(params[:id], :include => :re_artifact_properties) || ReAttachment.new
    
    # render html for tree
    @html_tree = create_tree
    
    if request.post?
      @re_attachment.attributes = params[:re_attachment]
      add_hidden_re_artifact_properties_attributes @re_attachment
      
      attachment_hash = params["attachment"] || {}
      attachment_uploaded = @re_attachment.attach_file(attachment_hash)

      return if !attachment_uploaded

			flash[:notice] = t(:re_attachment_saved, {:name => @re_attachment.name}) if save_ok = @re_attachment.save

      if save_ok && ! params[:parent_artifact_id].empty?
        @parent = ReArtifactProperties.find(params[:parent_artifact_id])
        @re_attachment.set_parent(@parent, 1)
      end			
			
      redirect_to :action => 'edit', :id => @re_attachment.id and return if save_ok
    end
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