class ReArtifactPropertiesController < RedmineReController
  unloadable
  menu_item :re

  def edit
    redirect 'edit'
  end

  def redirect action
    @re_artifact_properties = ReArtifactProperties.find_by_id(params[:id])

      
    if @re_artifact_properties.nil?
      render :template => 'error', :status => 500, :id => params[:id]
    else
      @project_id = params[:project_id]
      @redirect_id = @re_artifact_properties.artifact_id
      @redirect_controller = @re_artifact_properties.artifact_type.underscore

      logger.info("Redirecting from ReArtifactProperties (name=" + @re_artifact_properties.name + ", id="+ @re_artifact_properties.id.to_s +
              ") to instance (id=" + @redirect_id.to_s + " ,controller=" + @redirect_controller.to_s)


      if @redirect_controller.eql? 'Project'
        redirector  = { :controller => 'requirements', :action => 'index', :project_id => @project.id }
      else
        redirector = { :controller => @redirect_controller, :action => action, :id => @redirect_id, :project_id => @project_id }
      end
      
      redirector[:layout] = 'false' if request.xhr?

      redirect_to redirector
    end
  end
  
  def delete
    method = params[:mode]
    @artifact = ReArtifactProperties.find(params[:id])
    @project ||= @artifact.project

    @relationships_incoming = @artifact.relationships_as_sink
    @relationships_outgoing = @artifact.relationships_as_source
    @parent = @artifact.parent

    @children = gather_children(@artifact)
    
    @relationships_incoming.delete_if {|x| x.relation_type == 1 }
    @relationships_outgoing.delete_if {|x| x.relation_type == 1 }
    
    case method
      when 'move'
        @children = @artifact.children
        for child in @children
          child.set_parent(@parent)
        end
        @artifact.destroy

        flash[:notice] = t(:re_deleted_artifact_and_moved_children, :artifact => @artifact.name, :parent => @parent.name)
        redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
        
      when 'recursive'
        for child in @children
          child.destroy
        end
        @artifact.destroy

        flash[:notice] = t(:re_deleted_artifact_and_children, :artifact => @artifact.name)
        redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
      else
        @children = gather_children(@artifact)
    end
  end  

  def autocomplete_parent
    @artifact = ReArtifactProperties.find(params[:id]) unless params[:id].blank?    

    query = '%' + params[:parent_name].gsub ('%', '\%').gsub ('_', '\_').downcase + '%'
    @parents = ReArtifactProperties.find(:all, :conditions => ['name like ?', query ])

    if @artifact
      children = @artifact.gather_children
      @parents.delete_if{ |p| children.include? p }
      @parents.delete_if{ |p| p == @artifact } 
    end
    
    list = '<ul>'
    for parent in @parents
      list << '<li id="'
      list << parent.id.to_s
      list << '">'
      list << parent.name
      list << '</li>'
    end
    list << '</ul>'
    render :text => list   
  end
  
  private
  
  def gather_children(artifact)
    # recursively gathers all children for the given artifact
    #
    children = Array.new
    children.concat artifact.children
    return children if artifact.changed? || artifact.children.empty?
    for child in children
      children.concat gather_children(child)
    end
    children
  end
    

end