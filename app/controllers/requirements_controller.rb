class RequirementsController < RedmineReController
  unloadable
  menu_item :re

  def index
    initialize_tree_data
  end

  def delegate_tree_drop
    # The following method is called via if somebody drops an artifact on the tree.
    # It transmits the drops done in the tree to the database in order to last
    # longer than the next refresh of the browser.

    sibling_id = params[:sibling_id]
    moved_artifact_id = params[:id]
    insert_position = params[:position]

    moved_artifact = ReArtifactProperties.find(moved_artifact_id)

    new_parent = nil
    sibling = ReArtifactProperties.find(sibling_id)
    position = 1
    
    if sibling.parent_relation.nil? || sibling.artifact_type == "Project"      
      render :text => "insert position invalid", :status => 501
    else
    
      case insert_position
      when 'before'
        position = (sibling.position - 1) unless sibling.nil?
        new_parent = sibling.parent
      when 'after'
        position = (sibling.position + 1) unless sibling.nil?
        new_parent = sibling.parent
      when 'inside'
        position = 1
        new_parent = sibling
      else
        render :text => "insert position invalid", :status => 501
      end
      session[:expanded_nodes] << new_parent.id

      building_block_data = ReBbDataArtifactSelection.find(:first, :conditions => {:re_artifact_relationship_id => moved_artifact.parent_relation.id})
      building_block_data.delete unless building_block_data.nil?
      moved_artifact.parent_relation.remove_from_list
      moved_artifact.parent = new_parent
      moved_artifact.parent_relation.insert_at(position)

      result = {}
      result['status'] = 1
      result['insert_pos'] = position.to_s
      result['sibling'] = position.to_s + ' ' + sibling.name.to_s unless sibling.nil?

      render :json => result      
    end
    
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
    case params[:open]
      when 'data'
        ret = ''
        if node_id.eql? -1
          re_artifact_properties = ReArtifactProperties.find_by_project_id_and_artifact_type(@project.id, "Project")
          ret = create_tree(re_artifact_properties, 1)
        else
          session[:expanded_nodes] << node_id
          re_artifact_properties =  ReArtifactProperties.find(node_id)
          ret = render_json_tree(re_artifact_properties, 1)
        end
        render :json => ret
      when 'true'
        session[:expanded_nodes] << node_id
        render :text => "node #{node_id} opened"
      else
        session[:expanded_nodes].delete(node_id)
        render :text => "node #{node_id} closed"
    end
  end


  def sendDiagramPreviewImage 
    if @project.enabled_module_names.include? 'diagrameditor'            
       path = File.join(Rails.root, "files")
       filename = "diagram#{params[:diagram_id]}.png"
       path = File.join(path, filename)
       send_file path, :type => 'image/png', :filename => filename               
    end         
  end
  
  
#######
private
#######

end
