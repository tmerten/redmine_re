class ReSectionController < RedmineReController
  unloadable

  def new
    # redirects to edit to be more dry

    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_section = ReSection.find_by_id(params[:id], :include => :re_artifact_properties) || ReSection.new
    @project ||= @re_section.project
    
    # render html for tree
    @html_tree = create_tree
    
    if request.post?
      @re_section.attributes = params[:re_section]
      add_hidden_re_artifact_properties_attributes @re_section

      flash[:notice] = l(:re_section_saved) if save_ok = @re_section.save

      redirect_to :action => 'edit', :id => @re_section.id and return if save_ok
    end
  end

end