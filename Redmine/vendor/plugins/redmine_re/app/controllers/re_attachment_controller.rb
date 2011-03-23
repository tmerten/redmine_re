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

  def edit #todo: errorhandling of attachment and refactor
    @re_attachment = ReAttachment.find_by_id(params[:id], :include => :re_artifact_properties) || ReAttachment.new
    @project ||= @re_attachment.project
    #attachment_uploaded = false
    # render html for tree
    #@html_tree = create_tree #todo: temporary switched of because exception atm
    
    if request.post?
      @re_attachment.attributes = params[:re_attachment]
      add_hidden_re_artifact_properties_attributes @re_attachment

      if(@re_attachment.valid?)
        params["attachment"]["1"]["description"] = @re_attachment.name

        result = Attachment.attach_files(@re_attachment, params["attachment"])

       #attachment_uploaded = @re_attachment.unsaved_attachments.blank? && !result[:files].blank?
        #if !attachment_uploaded
        #  @re_attachment.errors.add("attachment", "no file choosed or filesize is 0 Byte")
        #end
        @re_attachment.attachment = result[:files][0]
        #Rails.logger.debug("###### edit ####1 " + result.inspect  + "\n" + @re_attachment.unsaved_attachments.inspect)
      end

			flash[:notice] = t(:re_attachment_saved, {:name => @re_attachment.name}) if save_ok = @re_attachment.save

      redirect_to :action => 'edit', :id => @re_attachment.id and return if save_ok
    end
  end

  def delete
  # deletes and updates the flash with either success, id not found error or deletion error
    @re_attachment = ReAttachment.find_by_id(params[:id], :include => :re_artifact_properties)
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