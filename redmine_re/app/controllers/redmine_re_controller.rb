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
  
  before_filter :find_project, :load_settings# , :authorize
  
	def load_settings
		@settings = Setting.plugin_redmine_re
		@re_artifact_order = ActiveSupport::JSON.decode(@settings['re_artifact_types'])
		@re_relation_order = ReArtifactProperties::RELATION_TYPES.keys
	end

  # uses redmine_re in combination with redmines base layout for the header unless it is an ajax-request
  layout proc{ |c| c.request.xhr? ? false : "redmine_re" } 

  def find_project
    # find the current project either by project name ( new action,..)
    if( params[:project_id] )
      return unless params[:project_id]
      begin
        @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    # or by artifact id ( edit action)
    else
      if (params[:id])
        begin
          controller_name = params[:controller]
          artifact = nil

          class_name = controller_name.classify
          begin
            artifact = class_name.constantize
            artifact = artifact.find(params[:id])
          rescue NameError
            artifact = ReArtifactProperties.find(params[:id])
          end
          @project = artifact.project
        rescue ActiveRecord::RecordNotFound
          render_404
        end
      #else# no project_id and no artifact id found
      # well, we tried everything, but we might still be able to display the page correctly
      #  render_404
      end
    end
  end
  
  def new
    artifact_type = self.controller_name
    logger.debug "############ CALLED NEW FOR ARTIFACT OF TYPE: " + artifact_type
    
    @artifact = artifact_type.camelcase.constantize.new
    @artifact_properties = @artifact.re_artifact_properties
    @bb_hash = ReBuildingBlock.find_all_bbs_and_data(@artifact_properties)
    if params[:parent_artifact_id]
      @parent = ReArtifactProperties.find(params[:parent_artifact_id])
    end
    
    new_hook params
    
    render :edit
  end
  
  def edit
    artifact_type = self.controller_name
    logger.debug "############ Called edit for artifact of type: " + artifact_type

    @artifact = artifact_type.camelcase.constantize.find_by_id(params[:id], :include => :re_artifact_properties) || artifact_type.camelcase.constantize.new
    @artifact_properties = @artifact.re_artifact_properties
    @parent = nil
    @bb_hash = ReBuildingBlock.find_all_bbs_and_data(@artifact_properties)
    
    unless params[:parent_artifact_id].blank?
      @parent = ReArtifactProperties.find(params[:parent_artifact_id])
    end
    
    edit_hook_after_artifact_initialized params
    
    if request.post?
      @artifact.attributes = params[artifact_type]
      # attributes that cannot be set by the user
      author = find_current_user
      @artifact.project_id = @project.id
      @artifact.updated_at = Time.now
      @artifact.updated_by = author.id
      @artifact.created_by = author.id  if @artifact.new_record?
  
      valid = @artifact.valid?
      valid = edit_hook_validate_before_save(params, valid) 

      if valid
        @artifact.save
        flash[:notice] = t(artifact_type + '_saved') if flash[:notice].blank?
        edit_hook_valid_artifact_after_save params
        @artifact.set_parent(@parent, 1) unless @parent.nil?
        # Saving of user defined Fields (Building Blocks)
        ReBuildingBlock.save_data(@artifact.re_artifact_properties.id, params[:re_bb])
        @bb_hash = ReBuildingBlock.find_all_bbs_and_data(@artifact_properties)
      else
        edit_hook_invalid_artifact_cleanup params
      end
    end # request.post? end
  end
  
  def new_hook(params)
    logger.debug("#############: new_hook not called")
  end

  def edit_hook_after_artifact_initialized(params)
    logger.debug("#############: edit_validate_before_save_hook not called")
  end
  
  def edit_hook_validate_before_save(params, artifact_valid)
    logger.debug("#############: edit_validate_before_save_hook not called")
    return true
  end
  
  def edit_hook_valid_artifact_after_save(params)
    logger.debug("#############: edit_valid_artifact_after_save_hook not called")
  end
  
  def edit_hook_invalid_artifact_cleanup(params)
    logger.debug("#############: edit_invalid_artifact_cleanup_hook not called")
  end
  
  def render_json_tree(re_artifact_properties, depth)
    # creates a tree of all children of re_artifact_properties
    # as json data
    tree = []
    for child in re_artifact_properties.children
      tree << create_tree(child, depth)
    end
    tree.to_json
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
  
  private
  
  def render_autocomplete_artifact_list_entry(artifact)
    # renders a list entry (<li> ... </li>) containing the artifacts name
    # and all its parent parents up to the project
    grandparents = []
    grandparent = artifact.parent
    unless grandparent.nil?
      while not grandparent.artifact_type.eql? "Project"
        grandparents << grandparent
        grandparent = grandparent.parent
      end
    end

    li = '<li id="'
    li << artifact.id.to_s
    li << '">'
    
    for gp in grandparents.reverse
      li << gp.name + " &rarr; "
    end
    
    li << "<b>" + artifact.name + "</b>"
    li << '</li>'
    li    
  end

  def create_tree(re_artifact_properties, depth = 0)
    #renders a re artifact and its children recursively as html tree
    session[:expanded_nodes] ||= Set.new
    session[:expanded_nodes].delete(re_artifact_properties.id) if re_artifact_properties.children.empty?
    expanded = session[:expanded_nodes].include?(re_artifact_properties.id)
    
    artifact_type = re_artifact_properties.artifact_type.to_s.underscore
    artifact_name = re_artifact_properties.name.to_s
    artifact_shortened_name = truncate(artifact_name, :length => TRUNCATE_NAME_IN_TREE_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    artifact_id = re_artifact_properties.id.to_s
    has_children = ! re_artifact_properties.children.empty?
    
    tree = {}
    tree['data'] = artifact_shortened_name
    tree['url'] = url_for :controller => artifact_type, :action => 'edit'
    if has_children
      tree ['state'] = 'open' if expanded
      tree ['state'] = 'closed' unless expanded
    end
    
    attr = {}
    attr['id'] = "node_" + artifact_id.to_s
    attr['rel'] = artifact_type
    attr['title'] = artifact_name
    
    tree['attr'] = attr
    
    if has_children
      tree['children'] = get_children(re_artifact_properties, depth-1)
    end
    
    tree
  end  

  def get_children(re_artifact_properties, depth)
    children = []
    expanded = session[:expanded_nodes].include?(re_artifact_properties.id)
    comma = false
    
    for child in re_artifact_properties.children
      if (depth > 0 or expanded )
        children << create_tree(child, depth)
      end
    end
    children
  end

end