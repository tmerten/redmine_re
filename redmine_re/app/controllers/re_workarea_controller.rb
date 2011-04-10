class ReWorkareaController < RedmineReController
  unloadable

  def new
    # redirects to edit to be more dry

    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_workarea = ReWorkarea.find_by_id(params[:id], :include => :re_artifact_properties) || ReWorkarea.new
    
    # render html for tree
    @html_tree = create_tree
    
    if request.post?
      @re_workarea.attributes = params[:re_workarea]
      add_hidden_re_artifact_properties_attributes @re_workarea

      flash[:notice] = t(:re_workarea_saved) if save_ok = @re_workarea.save

      if save_ok && ! params[:parent_artifact_id].empty?
        @parent = ReArtifactProperties.find(params[:parent_artifact_id])
        @re_workarea.set_parent(@parent, -1)
      end
      
      redirect_to :action => 'edit', :id => @re_workarea.id and return if save_ok
    end
  end
end