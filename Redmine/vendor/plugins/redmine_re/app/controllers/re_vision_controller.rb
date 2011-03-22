class ReVisionController < RedmineReController
  unloadable
  def index
  
    @re_visions = ReVision.find(:all,
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
    @re_vision = ReVision.find_by_id(params[:id], :include => :re_artifact_properties) || ReVision.new
    @project ||= @re_vision.project
    
    # render html for tree
    @html_tree = create_tree
    
    if request.post?
      @re_vision.attributes = params[:re_vision]
      add_hidden_re_artifact_properties_attributes @re_vision

			flash[:notice] = t(:re_vision_saved, {:name => @re_vision.name}) if save_ok = @re_vision.save

      redirect_to :action => 'edit', :id => @re_vision.id and return if save_ok
    end
  end

  def delete
  # deletes and updates the flash with either success, id not found error or deletion error
    @re_vision = ReVision.find_by_id(params[:id], :include => :re_artifact_properties)
    if !@re_vision
      flash[:error] = t(:re_vision_not_found, {:id => @params[:id] })
    else
      name = @re_vision.name
      if ReVision.destroy(@re_vision.id)
        flash[:notice] = t(:re_vision_deleted, {:name => name})
      else
				flash[:error] = t(:re_vision_not_deleted, {:name => name})
      end
    end
    redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
  end

end