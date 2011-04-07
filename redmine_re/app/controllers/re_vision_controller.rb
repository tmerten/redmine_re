class ReVisionController < RedmineReController
  unloadable

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
end