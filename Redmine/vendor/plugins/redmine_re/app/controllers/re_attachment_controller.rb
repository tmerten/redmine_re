class ReAttachmentController < RedmineReController
  unloadable
  def index
  
    @re_attachments = ReAttachment.find(:all,
                         :joins => :re_artifact_properties,
                         :conditions => {:re_artifact_properties => {:project_id => @project.id}}
    )
    render :layout => false if params[:layout] == 'false'
  end

  def new
    # redirects to edit to be more dry

    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_attachment = ReAttachment.find_by_id(params[:id], :include => :re_artifact_properties) || ReAttachment.new
    @project ||= @re_attachment.project
    
    # render html for tree
    @html_tree = create_tree
    
    if request.post?
      @re_attachment.attributes = params[:re_attachment]
      add_hidden_re_artifact_properties_attributes @re_attachment

      attachment_hash = params["attachment"] || {}
      attachment_uploaded = @re_attachment.attach_file(attachment_hash)

      return if !attachment_uploaded
      @re_attachment.attachment.description = @re_attachment.name
      @re_attachment.attachment.save
      
			flash[:notice] = t(:re_attachment_saved, {:name => @re_attachment.name}) if save_ok = @re_attachment.save

      redirect_to :action => 'edit', :id => @re_attachment.id and return if save_ok
    end
  end

  def show
    if @attachment.image? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
      @content = File.new(@attachment.diskfile, "rb").read
      render :action => 'file'
    else
      download
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

  def delete
  # deletes and updates the flash with either success, id not found error or deletion error
    @re_attachment = ReAttachment.find_by_id(params[:id], :include => :re_artifact_properties)
    @project ||= @re_attachment.project

    if !@re_attachment
      flash[:error] = t(:re_attachment_not_found, {:id => @params[:id] })
    else
      name = @re_attachment.name
      if ReAttachment.destroy(@re_attachment.id)
        
        flash[:notice] = t(:re_attachment_deleted, {:name => name})
      else
				flash[:error] = t(:re_attachment_not_deleted, {:name => name})
      end
    end
    redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
  end

end