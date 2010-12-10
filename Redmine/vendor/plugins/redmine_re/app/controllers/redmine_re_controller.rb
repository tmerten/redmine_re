##
# super controller for the redmine RE plugin
# common methods used for (almost) all redmine_re controllers go here
class RedmineReController < ApplicationController
  unloadable
  
  TRUNCATE_NAME_IN_TREE_AFTER_CHARS = 18
  TRUNCATE_OMISSION = "..."
  
  #include ActionView::Helpers::UrlHelper
  #include ActionView::Helpers::AssetTagHelper
  #include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper  

  before_filter :find_project
  #before_filter :authorize,
               # :except =>  [:delegate_tree_drop, :delegate_tree_node_click]

  # uses redmine_re in combination with redmines base layout for the header unless it is an ajax-request
  layout proc{ |c| c.request.xhr? ? false : "redmine_re" } 
  
  # marks 'Requirements' (css class=re) as the selected menu item
  menu_item :re

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
    artifacts = ReArtifactProperties.find_all_by_project_id(@project.id)
    # artifacts = [] if artifacts.nil?

    html_tree = '<ul id="tree">'
    for artifact in artifacts
      if (artifact.parent.nil?)
        html_tree += render_to_html_tree(artifact, 0)
      end
    end
    html_tree += '</ul>'
    
    html_tree
  end
  

  ##
  # The following method is called via JavaScript Tree by an ajax request.
  # It transmits the drops done in the tree to the database in order to last
  # longer than the next refresh of the browser.
  def delegate_tree_drop
    new_parent_id = params[:new_parent_id]
    moved_artifact_id = params[:moved_artifact_id]
    child = ReArtifactProperties.find_by_id(moved_artifact_id)
    if new_parent_id == 'null'
      # Element is dropped under root node which is the project new parent-id has to become nil.
      child.parent = nil
    else
      # Element is dropped under other artifact
      child.parent = ReArtifactProperties.find(new_parent_id)
    end
    child.state = State::DROPPING    #setting state for observer
    child.save!
    render :nothing => true
  end

  ##
  # The following method is called via JavaScript Tree by an ajax update request.
  # It transmits the call to the according controller which should render the detail view
  def delegate_tree_node_click
    artifact = ReArtifactProperties.find_by_id(params[:id])
    redirect_to url_for :controller => params[:artifact_controller], :action => 'edit', :id => params[:id], :parent_id => artifact.parent_artifact_id, :project_id => artifact.project_id
  end

  #renders a re artifact and its children recursively as html tree
  def render_to_html_tree(re_artifact_properties, depth = 0)
    session[:expanded_nodes] ||= Set.new
    expanded = session[:expanded_nodes].include?(re_artifact_properties.id)
    artifact_type = re_artifact_properties.artifact_type.to_s.underscore
    html_tree = ''
    
    html_tree += '<li id="node_' + re_artifact_properties.id.to_s #IDs must begin with a letter(!)
    html_tree += '" class="' + artifact_type
    if re_artifact_properties.children.empty?
      html_tree += ' empty'
    else
      html_tree += ' closed' unless (depth > 1 || expanded )
      logger.debug('############ depth: ' + depth.to_s + ' is included: ' + session[:expanded_nodes].include?(re_artifact_properties.id).to_s )
    end
    html_tree += '" style="position: relative;">'
    html_tree += '<span class="handle"></span>'
    html_tree += '<a class="nodelink">' 
    html_tree += truncate(re_artifact_properties.name.to_s, :length => TRUNCATE_NAME_IN_TREE_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    html_tree += '</a>'
    html_tree += '<a href="' + url_for( :controller => artifact_type, :action => 'edit', :id => re_artifact_properties.artifact_id) + '" class="nodeeditlink"> (' + l(:re_edit) + ')</a>'

    html_tree += '<ul>'  if expanded
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
    re_artifact_properties =  ReArtifactProperties.find(node_id)
    ret = ''

    if params[:open] == 'true'
      session[:expanded_nodes] << node_id
      ret = render_to_html_tree(re_artifact_properties, 1)
    else
      session[:expanded_nodes].delete(node_id)
      ret = render_to_html_tree(re_artifact_properties, 0)
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
end