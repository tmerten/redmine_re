class RequirementsController < RedmineReController
  unloadable
  menu_item :re

  def index
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    
    if @project_artifact.nil?
      redirect_to :action => "setup", :project_id => @project.id
    end
  end

  def setup
    @project_artifact = nil
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    if @project_artifact.nil?
      @project_artifact = ReArtifactProperties.new 
      @project_artifact.project = @project
      @project_artifact.created_by = User.first # is there a better solution?
      @project_artifact.updated_by = User.first # actually this is not editable anyway
      @project_artifact.artifact_type = "Project"
      @project_artifact.artifact_id = @project.id
      @project_artifact.description = @project.description
      @project_artifact.priority = 50
      @project_artifact.name = @project.name
      @project_artifact.save
    end
  end
  
  def configure
  for artifact_type in @re_artifact_order
	  configured_artifact = ReArtifactsConfig.find_by_artifact_type(artifact_type)
	  if configured_artifact.nil?
      configured_artifacts = ReArtifactsConfig.all
      configured_artifacts.sort_by {|x| x.position }
      position = configured_artifacts.last.position
      configuration = ReArtifactsConfig.new( :artifact_type => artifact_type, :position => position )
      configuration.save
    end
	end
    
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    @re_artifacts_configs = ReArtifactsConfig.all
    @config = {}
    settings = {}
    settings['relation_management_pane'] = 'true'
    @config['settings'] = settings
    
    for artifact_config in @re_artifacts_configs
      artifact_type = artifact_config.artifact_type
      config[artifact_type] = artifact_config
    end
    
    
  end

  def delegate_tree_drop
    # The following method is called via if somebody drops an artifact on the tree.
    # It transmits the drops done in the tree to the database in order to last
    # longer than the next refresh of the browser.
    new_parent_id = params[:new_parent_id]
    ancestor_id = params[:ancestor_id]
    moved_artifact_id = params[:id]
    insert_postition = params[:position]

    moved_artifact = ReArtifactProperties.find(moved_artifact_id)
    
		new_parent = nil
		begin
	 	  new_parent = ReArtifactProperties.find(new_parent_id) if not new_parent_id.empty?
		rescue ActiveRecord::RecordNotFound
      new_parent = ReArtifactProperties.find_by_project_id_and_artifact_type(moved_artifact.project_id, "Project")
		end
    session[:expanded_nodes] << new_parent.id
		
		ancestor = nil
    ancestor = ReArtifactProperties.find(ancestor_id) if not ancestor_id.empty?

    position = 1
    
    case insert_postition
    when 'before'
      position = (ancestor.position - 1) unless ancestor.nil? || ancestor.position.nil?
    when 'after'
      position = (ancestor.position + 1) unless ancestor.nil? || ancestor.position.nil?
    else
      position = 1
    end
      
    
    moved_artifact.set_parent(new_parent, position)
   
    result = {}
    result['status'] = 1
    result['insert_pos'] = position.to_s
    result['ancestor'] = ancestor.position.to_s + ' ' + ancestor.name.to_s unless ancestor.nil? || ancestor.position.nil?
    
    render :json => result
  end

  # first tries to enable a contextmenu in artifact tree
  def context_menu
    @artifact =  ReArtifactProperties.find_by_id(params[:id])

    render :text => "Could not find artifact.", :status => 500 unless @artifact

    @subartifact_controller = @artifact.artifact_type.to_s.underscore
    @back = params[:back_url] || request.env['HTTP_REFERER']

    render :layout => false
  end

  def treestate
    # this method saves the state of a node
    # i.e. when you open or close a node in the tree
    # this state will be saved in the session
    # whenever you render the tree the rendering function will ask the
    # session for the nodes that are "opened" to render the children
    node_id = params[:id].to_i
    ret = ''
    case params[:open]
    when 'data'
      if node_id.eql? -1
        re_artifact_properties = ReArtifactProperties.find_by_project_id_and_artifact_type(@project.id, "Project")
      else
        session[:expanded_nodes] << node_id
        re_artifact_properties =  ReArtifactProperties.find(node_id)
      end
      ret = render_json_tree(re_artifact_properties, 1)
      render :json => ret
    when 'true'
      session[:expanded_nodes] << node_id
      render :text => "node #{node_id} opened"
    else
      session[:expanded_nodes].delete(node_id)
      render :text => "node #{node_id} closed"
    end
  end  
end