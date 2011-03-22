##
# super controller for the redmine RE plugin
# common methods used for (almost) all redmine_re controllers go here
class RedmineReController < ApplicationController
  unloadable
  menu_item :re
  
  TRUNCATE_NAME_IN_TREE_AFTER_CHARS = 18
  TRUNCATE_OMISSION = "..."
  NODE_CONTEXT_MENU_ICON = "bullet_toggle_plus.png"

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  
  before_filter :find_project, :load_settings
  
  #before_filter :authorize,
               # :except =>  [:delegate_tree_drop, :delegate_tree_node_click]

	def load_settings
		@settings = Setting.plugin_redmine_re
		@re_artifact_order = ActiveSupport::JSON.decode(@settings['re_artifact_types'])
	end

  # uses redmine_re in combination with redmines base layout for the header unless it is an ajax-request
  layout proc{ |c| c.request.xhr? ? false : "redmine_re" } 
  
  def find_project
    # find the current project either by project name
    return unless params[:project_id]
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  def save_re_tree_structure
    @treestructure = params[:treestructure]
  end

  def add_hidden_re_artifact_properties_attributes re_artifact
    # this adds user-unmodifiable attributes to the re_artifact_properties
    # the re_artifact_properties is a superclass of all other artifacts (goals, tasks, etc)
    # this method should be called after initializing or loading any artifact object
    author = find_current_user
    re_artifact.project_id = @project.id
    re_artifact.updated_at = Time.now
    re_artifact.updated_by = author.id
    re_artifact.created_by = author.id  if re_artifact.new_record?
  end
  
  def create_tree
    show_projects = params[:show_projects]
    artifacts = nil
    
    if show_projects
      artifacts = ReArtifactProperties.find_all_by_artifact_type("Project")
    else
      project_artifact = ReArtifactProperties.find_by_project_id_and_artifact_type(@project.id, "Project")
      artifacts = project_artifact.children
    end
    
    html_tree = '<ul id="tree">'
    for artifact in artifacts
      html_tree += render_to_html_tree(artifact, 0)
    end
    html_tree += '</ul>'
    
    html_tree
  end
  
  def delegate_tree_drop
    # The following method is called via if somebody drops an artifact on the tree.
    # It transmits the drops done in the tree to the database in order to last
    # longer than the next refresh of the browser.
    new_parent_id = params[:new_parent_id]
    left_artifact_id = params[:left_artifact_id]
    moved_artifact_id = params[:moved_artifact_id]

    moved_artifact = ReArtifactProperties.find(moved_artifact_id)
    
		new_parent = nil
		begin
	 	  new_parent = ReArtifactProperties.find(new_parent_id) if not new_parent_id.empty?
		rescue ActiveRecord::RecordNotFound
      new_parent = ReArtifactProperties.find_by_project_id_and_artifact_type(moved_artifact.project_id, "Project")
		end

		left_artifact = nil
    left_artifact = ReArtifactProperties.find(left_artifact_id) if not left_artifact_id.empty?

    position = 1
    position = (left_artifact.position + 1) unless left_artifact.nil? || left_artifact.position.nil?
    
    moved_artifact.set_parent(new_parent, position)
   
    #render :nothing => true
    debugtext = 'insert position: ' + position.to_s + ' - left '
    debugtext += left_artifact.position.to_s + ' ' + left_artifact.name.to_s unless left_artifact.nil? || left_artifact.position.nil?
    
    render :text => debugtext
  end

  def render_to_html_tree(re_artifact_properties, depth = 0)
    #renders a re artifact and its children recursively as html tree
    session[:expanded_nodes] ||= Set.new
    session[:expanded_nodes].delete(re_artifact_properties.id) if re_artifact_properties.children.empty?

    expanded = session[:expanded_nodes].include?(re_artifact_properties.id)
    
    artifact_type = re_artifact_properties.artifact_type.to_s.underscore
    artifact_name = re_artifact_properties.name.to_s
    html_tree = ''
    
    html_tree += '<li id="node_' + re_artifact_properties.id.to_s #HTML-IDs must begin with a letter(!)
    html_tree += '" class="' + artifact_type
    if re_artifact_properties.children.empty?
      html_tree += ' empty'
    else
      html_tree += ' closed' unless (depth > 1 || expanded )
      logger.debug('############ depth: ' + depth.to_s + ' is included: ' + session[:expanded_nodes].include?(re_artifact_properties.id).to_s )
    end
    html_tree += '" style="position: relative;">'
    html_tree += '<span class="handle"></span>'
    html_tree += '<a class="nodelink ' + artifact_type + '"'
    html_tree += ' title="' + artifact_name + '"' unless artifact_name.length < TRUNCATE_NAME_IN_TREE_AFTER_CHARS
    html_tree += '">'

    #html_tree += ' ' + re_artifact_properties.position.to_s + ' ' unless re_artifact_properties.artifact_type == 'Project'
    
    html_tree += truncate(artifact_name, :length => TRUNCATE_NAME_IN_TREE_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    html_tree += '</a>'
    html_tree += '<a class="nodecontextmenulink">'
    html_tree += image_tag('icons/' + NODE_CONTEXT_MENU_ICON, :alt => l(:re_treenode_context_menu), :plugin => "redmine_re")
    html_tree += '</a>'

    html_tree += '<ul>' if expanded
    if ( !re_artifact_properties.children.empty? )
      html_tree += render_children_to_html_tree(re_artifact_properties, depth-1)
    end
    html_tree += '</ul>' if expanded
  
    html_tree += '</li>'
  end
  
  def render_children_to_html_tree(re_artifact_properties, depth)
    expanded = session[:expanded_nodes].include?(re_artifact_properties.id)
    html_tree = ''
    
    for child in re_artifact_properties.children
      if (depth > 0 or expanded )
        html_tree += render_to_html_tree(child, depth)
      end
    end
    html_tree    
  end
  
  def treestate
    node_id = params[:id].to_i
    ret = ''
    if params[:open] == 'true'
      session[:expanded_nodes] << node_id
      re_artifact_properties =  ReArtifactProperties.find(node_id)
      ret = render_children_to_html_tree(re_artifact_properties, 1)
    else
      session[:expanded_nodes].delete(node_id)
    end

    render :inline => ret
  end

  # first tries to enable a contextmenu in artifact tree
  def context_menu
    @artifact =  ReArtifactProperties.find_by_id(params[:id])

    render :text => "Could not find artifact.", :status => 500 unless @artifact

    @subartifact_controller = @artifact.artifact_type.to_s.underscore
    @back = params[:back_url] || request.env['HTTP_REFERER']

    render :layout => false
  end

  # filtering of re_artifacts. If request is post, filter was used already
  # and result should be displayed
  def enhanced_filter
    @project_id = params[:project_id]

    if request.post? # apply filter and show results
      source = params[:re_source_artifact][:data]
      source_searching = params[:re_source_artifact][:searching]
      sink = params[:re_sink_artifact][:data]
      sink_searching =  params[:re_sink_artifact][:searching]
      source.delete_if {|key, value| value == ""}
      sink.delete_if {|key, value| value == ""}
      # search for artifacts matching the source_artifact_filter_criteria
      if params[:activated_searches].key?(:re_source_artifact)
        first_param = source.each.first
        condition_hash = build_conditions_hash(filter_param, searching_forms, artifact_type)
        @source_artifacts = find_first_artifacts_with_first_parameter(first_param, condition_hash, params[:re_source_artifact][:type])
        source.delete(first_param[0])
        # run through all given parameters and reduce the set of artifacts matching with each step
        for key in source.keys do
         @source_artifacts = reduce_search_result_with_parameter(@source_artifacts, key, source[key], source_searching[key])
        end

      end
      # search was only about artifacts, not about relationships
      # therefore just display artifacts without taking relationships into account
      render 'requirements/filter_results_simple'
      return
    end
    render 'requirements/enhanced_filter'
  end

  # This method evaluates the parameters from the filter and builds up the parts to form a 
  def build_conditions_hash(filter_param, searching_forms, artifact_type) # Todo: Muss erledigt werden!
    
  end


  # This method takes a 2 value array with the name of the attribute to search for and its value;
  # it takes the hash with the searching forms like start with, greater_than and so on;
  # finally it takes the chosen artifact type to reduce the search.
  # The method evaluates the given parameter to find artifacts matching these first two
  # criteria (type and the first_param).
  def find_first_artifacts_with_first_parameter(filter_param, condition_hash, artifact_type)
    artifacts = []
    artifact_properties_attribute = false
    for column in ReArtifactProperties.content_columns do
     artifact_properties_attribute = true if column.name == filter_param[0] 
    end
     
     # if attribute searched for belongs to RePropertiesAttributes, one can search for the artifact in ReArtifactProperties
     if artifact_properties_attribute # ReArtifactProperties.has_attribute?(filter_param[0])
            artifacts += ReArtifactProperties.find(:all, :conditions => [filter_param[0] + " LIKE ? AND artifact_type = ?", filter_param[1] + '%', artifact_type])
     # attribute is a special one used by one of the subclasses of ReArtifactProperties
     else
      case artifact_type
        when "ReSubtask", ""
            artifacts += ReSubtask.find(:all, :conditions => [filter_param[0] + " = ?", filter_param[1]])
        when "ReTask", ""
            artifacts += ReTask.find(:all, :conditions => [filter_param[0] + " = ?", filter_param[1]])
        when "ReGoal", ""
            artifacts += ReSubtask.find(:all, :conditions => [filter_param[0] + " = ?", filter_param[1]])
      end
     end
  end

  def reduce_search_result_with_parameter(source_artifacts, key, source_key, source_searching_key)

  end

end