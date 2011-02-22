class ReSectionController < RedmineReController
  unloadable
  def index
  
    @re_sections = ReSection.find(:all,
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

  def delete
  # deletes and updates the flash with either success, id not found error or deletion error
    @re_section = ReSection.find_by_id(params[:id], :include => :re_artifact_properties)
    @project ||= @re_section.project

    if !@re_section
      flash[:error] = t(:re_section_not_found, {:id => @params[:id] })
    else
      name = @re_section.name
      if ReSection.destroy(@re_section.id)
        flash[:notice] = t(:re_section_deleted, {:name => name})
      else
        flash[:error] = t(:re_section_not_deleted, {:name => name})
      end
    end
    redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
  end

end