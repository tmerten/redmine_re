include ReApplicationHelper

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

    moved_artifact_id = params[:id]
    insert_position = params[:position]
    parent_id = params[:parent_id]
    
    moved_artifact = ReArtifactProperties.find(moved_artifact_id)
    new_parent = ReArtifactProperties.find(parent_id)

    result = {}

    moved_artifact.parent_relation.remove_from_list
    moved_artifact.parent = new_parent

    if insert_position == 0 # insert inside
      moved_artifact.parent_relation.insert_at(1)
      result['status'] = 1
      result['insert_pos'] = 1
    else
      moved_artifact.parent_relation.insert_at(insert_position.to_i + 1)
      result['status'] = 1
      result['insert_pos'] = 1
    end

    render :json => result
  end

  # first tries to enable a contextmenu in artifact tree
  def context_menu
    @artifact =  ReArtifactProperties.find_by_id(params[:id])

    render :text => "Could not find artifact.", :status => 400 unless @artifact

    @subartifact_controller = @artifact.artifact_type.to_s.underscore
    @back = params[:back_url] || request.env['HTTP_REFERER']

    render :layout => false
  end

  # saves the state of a node i.e. when you open or close a node in
  # the tree this state will be saved in the session
  # whenever you render the tree the rendering function will ask the
  # session for the nodes that are "opened" to render the children
  def tree
    node_id = params[:id].to_i
    case params[:mode]
      when 'data'
        session[:expanded_nodes] << node_id
        re_artifact_properties = ReArtifactProperties.find(node_id)
        tree = []
        for child in re_artifact_properties.children
          tree << create_tree(child)
        end
        render :json => tree.to_json
      when 'root'
        tree = []
        tree << create_tree(@project_artifact)
        render :json => tree.to_json
      when 'open'
        session[:expanded_nodes] << node_id
        render :text => "node #{node_id} opened"
      else
        session[:expanded_nodes].delete(node_id)
        render :text => "node #{node_id} closed"
    end
    logger.debug("Expended nodes: #{session[:expanded_nodes].inspect}")
  end

  def sendDiagramPreviewImage 
    if @project.enabled_module_names.include? 'diagrameditor'
       path = File.join(Rails.root, "files")
       filename = "diagram#{params[:diagram_id]}.png"
       path = File.join(path, filename)
       send_file path, :type => 'image/png', :filename => filename
    end         
  end
  
  def add_relation
    @source = ReArtifactProperties.find_by_id(params[:source_id]);
    @sink = ReArtifactProperties.find_by_id(params[:sink_id]);
    @re_artifact_properties = ReArtifactProperties.find_by_id(params[:id])
        
    if (@source.blank? || @sink.blank? || @re_artifact_properties.blank? )
        render :text => t(:re_404_artifact_not_found), :status => 404
    elsif (!params[:re_artifact_relationship].blank?)
      
      relation_type = params[:re_artifact_relationship][:relation_type]
      new_relation = ReArtifactRelationship.new(:sink_id => @sink.id, :source_id => @source.id, :relation_type => relation_type)
        
      if new_relation.save        
        flash[:notice] = t(:re_relation_saved)
        redirect_to @re_artifact_properties        
      else
        flash[:error] = t(:re_relation_saved_error)
        redirect_to @re_artifact_properties
      end        
    elsif params[:dialog_send].nil?
      #display add relation dialog        
      render :file => 'requirements/add_relation', :formats => [:html], :layout => false
    else
      #no relation type was selected
      flash[:error] = t(:re_relation_saved_error)
      redirect_to @re_artifact_properties                   
    end
  end

#######
private
#######

end