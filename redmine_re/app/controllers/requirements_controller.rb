class RequirementsController < RedmineReController
  unloadable
  menu_item :re

  def index
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    
    if @project_artifact.nil? || @re_artifact_order.nil? || @re_relation_order.nil?
      redirect_to :action => "configure", :project_id => @project.id
    end
  end
  
  def configure
    initialize_artifact_order(@project.id)
    initialize_relation_order(@project.id)
    
    @project_artifact = nil
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    if @project_artifact.nil? # aka re plugin definetely unconfigured for this project
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

    if request.post?
      #store new settings and configurations
      new_settings = params[:re_settings]
      new_artifact_order = ActiveSupport::JSON.decode(params[:re_artifact_order])
      new_relation_order = ActiveSupport::JSON.decode(params[:re_relation_order])

      ReSetting.set_plain("relation_management_pane", @project.id, new_settings.has_key?("relation_management_pane").to_s)
      ReSetting.set_plain("visualization_size", @project.id, new_settings["visualization_size"])

      ReSetting.set_serialized("artifact_order", @project.id, new_artifact_order)
      ReSetting.set_serialized("relation_order", @project.id, new_relation_order)
      
      new_artifact_configs = params[:re_artifact_configs]
      new_artifact_configs.each_pair do |k,v|
        # disabled checkboxes do not send a key/value pair
        v['in_use'] = v.has_key? 'in_use'
        v['printable'] = v.has_key? 'printable'
        v['show_children_in_tree'] = v.has_key? 'show_children_in_tree'
        logger.debug('storing:' + k + ' ' + @project.id.to_s + ' ' + v.to_yaml)
        ReSetting.set_serialized(k, @project.id, v)
      end

      new_relation_configs = params[:re_relation_configs]
      new_relation_configs.each_pair do |k, v|
        v['in_use'] = v.has_key? 'in_use'
        v['show_in_visualization'] = v.has_key? 'show_in_visualization'
        v['directed'] = v.has_key? 'directed'
        ReSetting.set_serialized(k, @project.id, v)
      end

      @re_artifact_order = ReSetting.get_serialized("artifact_order", @project.id)
      @re_relation_order = ReSetting.get_serialized("relation_order", @project.id)      

      flash[:notice] = t(:re_configs_saved)
    end
    
    # checking all artifacts should be done every time for now
    # since we are still adding new stuff which otherwise does
    # not get configured appropriately
    # Anyway, it does not take much time and its done only in here
    @re_artifact_configs = {}
    @re_artifact_order.each do |artifact_type|
      configured_artifact = ReSetting.get_serialized(artifact_type, @project.id)
      if configured_artifact.nil?
        logger.debug("##### found an unconfigured artifact of type '" + artifact_type.to_s + "', creating an initial configuration")
        configured_artifact = {}
        configured_artifact['in_use'] = true
        configured_artifact['alias'] = artifact_type.gsub(/^re_/, '').humanize
        configured_artifact['printable'] = true
        configured_artifact['color'] = "%06x" % (rand * 0xffffff)
        configured_artifact['show_children_in_tree'] = true
        ReSetting.set_serialized(artifact_type, @project.id, configured_artifact)
      end
      @re_artifact_configs[artifact_type] = configured_artifact
    end

    @re_relation_configs = {}
    @re_relation_order.each do |relation_type|
      configured_relation = ReSetting.get_serialized(relation_type, @project.id)
      if configured_relation.nil?
        logger.debug("##### found an unconfigured relation of type '" + relation_type.to_s + "', creating an initial configuration")
        configured_relation = {}
        configured_relation['in_use'] = true
        configured_relation['alias'] = relation_type.humanize
        configured_relation['color'] = "%06x" % (rand * 0xffffff)
        configured_relation['show_in_visualization'] = true
        ReSetting.set_serialized(relation_type, @project.id, configured_relation)
      end
      @re_relation_configs[relation_type] = configured_relation
    end

    @re_settings = {}
    @re_settings["relation_management_pane"] = "true".eql?(ReSetting.get_plain("relation_management_pane", @project.id))
    @re_settings["relation_management_pane"] ||= false
    @re_settings["visualization_size"] = ReSetting.get_plain("visualization_size", @project.id)
    @re_settings["visualization_size"] ||= 800

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

#######
private
#######

  def initialize_artifact_order(project_id)
    configured_artifact_types = Array.new
    stored_settings = ReSetting.get_serialized("artifact_order", project_id)
    configured_artifact_types.concat(stored_settings) if stored_settings
    
    all_artifact_types = Dir["#{RAILS_ROOT}/vendor/plugins/redmine_re/app/models/re_*.rb"].map do |f|
      fd = File.open(f, 'r')
      File.basename(f, '.rb') if fd.read.include? "acts_as_re_artifact"
    end
  
    all_artifact_types.delete_if { |x| x.nil? }
    all_artifact_types.delete(:ReArtifactProperties)
    all_artifact_types.delete(:ReArtifactsConfig)
    all_artifact_types.delete_if { |v| configured_artifact_types.include? v }
    configured_artifact_types.concat(all_artifact_types)
  
  
    logger.debug(configured_artifact_types.to_yaml)
    
    ReSetting.set_serialized("artifact_order", project_id, configured_artifact_types)
    @re_artifact_order = configured_artifact_types
  end
  
  def initialize_relation_order(project_id)
    configured_relation_types = Array.new
    stored_settings = ReSetting.get_serialized("relation_order", project_id)
    configured_relation_types.concat(stored_settings) if stored_settings
    
    all_relation_types = []
    ReArtifactRelationship::RELATION_TYPES.values.each { |k| all_relation_types << k.to_s }
    all_relation_types.delete_if { |v| configured_relation_types.include? v }
    configured_relation_types.concat(all_relation_types)
    
    @re_relation_order = configured_relation_types
  end

end