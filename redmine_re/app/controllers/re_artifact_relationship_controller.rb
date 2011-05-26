class ReArtifactRelationshipController < RedmineReController
  unloadable
  menu_item :re
  
  TRUNCATE_NAME_IN_VISUALIZATION_AFTER_CHARS = 18
  TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS = 150
  TRUNCATE_OMISSION = "..."
  
  include ActionView::Helpers::JavaScriptHelper

  def delete
    @relation = ReArtifactRelationship.find(params[:id])

    unless( @relation.relation_type.eql?(ReArtifactProperties::RELATION_TYPES[:parentchild]) )
      @relation.destroy
    end

    @re_artifact_properties = ReArtifactProperties.find(params[:re_artifact_properties_id])
    @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(params[:re_artifact_properties_id])
    @relationships_outgoing.delete_if { |rel| rel.relation_type.eql?(ReArtifactProperties::RELATION_TYPES[:parentchild])}
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(params[:re_artifact_properties_id])
    @relationships_incoming.delete_if { |rel| rel.relation_type.eql?(ReArtifactProperties::RELATION_TYPES[:parentchild])}

    render :partial => "relationship_links", :project_id => params[:project_id]
  end

  def autocomplete_sink
    @artifact = ReArtifactProperties.find(params[:id]) unless params[:id].blank?

    query = '%' + params[:sink_name].gsub('%', '\%').gsub('_', '\_').downcase + '%'
    @sinks = ReArtifactProperties.find(:all, :conditions => ['name like ?', query ])

    if @artifact
      @sinks.delete_if{ |p| p == @artifact }
    end

    list = '<ul>'
    for sink in @sinks
      list << render_autocomplete_artifact_list_entry(sink)
    end
    list << '</ul>'
    render :text => list
  end
  
  def prepare_relationships
    artifact_properties_id = ReArtifactProperties.get_properties_id(params[:original_controller], params[:id])
    relation = params[:re_artifact_relationship]

    if relation[:relation_type].eql?("parentchild")
      raise ArgumentError, "You are not allowed to create a parentchild relationship!"
    end

    if relation[:relation_type] && relation[:artifact_id]
      source = ReArtifactProperties.find_by_id(artifact_properties_id)
      sink = ReArtifactProperties.find_by_id(relation[:artifact_id]) 
      source.relate_to(sink, relation[:relation_type].to_sym, false)
    else
    	@error = t(:re_relationship_create_error)
    end

    @re_artifact_properties = ReArtifactProperties.find(artifact_properties_id)
    @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(artifact_properties_id)
    @relationships_outgoing.delete_if { |rel| rel.relation_type.eql?(ReArtifactProperties::RELATION_TYPES[:parentchild])}
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(artifact_properties_id)
    @relationships_incoming.delete_if { |rel| rel.relation_type.eql?(ReArtifactProperties::RELATION_TYPES[:parentchild])}

    render :partial => "relationship_links", :layout => false, :project_id => params[:project_id]
  end

  def visualization
    # Building JSON-Tree for Netmap-Visualization. As the JIT-Sunburst-Visualization
    # is usually build for trees, we have to add a dummy root element which isn't shown
    # and insert all the artifacts we are interested in as children of this very root node
    @artifacts = ReArtifactProperties.find_all_by_project_id(@project.id, :order => "artifact_type, name")
    @artifacts.delete_if { |a| a.artifact_type.eql? 'Project' }
    
    #@artifacts = ReArtifactProperties.find(:all, :order => "name", :conditions => ["project_id = ? and artifact_type = ?", params[:project_id], "ReGoal"])
    @json_netmap = build_json_for_netmap(@artifacts)
    # preparing html for tree view
  end

  def build_json_for_netmap(artifacts, relation_search_string = nil)
    json = []

    rootnode = {}
    rootnode['id'] = "node0"
    rootnode['name'] = "Project"
    
    root_node_data = {}
    root_node_data['$type'] = "none"
    rootnode['data'] = root_node_data

    if @show_tree
      re_artifact_properties = ReArtifactProperties.find_by_project_id_and_artifact_type(@project.id, "Project")
      
      children= gather_children(re_artifact_properties)
      rootnode['children'] = children
      
      json = rootnode
    else
    
      adjacencies = []
      for artifact in artifacts do
        adjacent_node = {}
        adjacent_node['nodeTo'] = "node_" + artifact.id.to_s
        edge_data = {}
        edge_data['$type'] = "none"
        adjacent_node['data'] = edge_data
        adjacencies << adjacent_node      
      end
      
      rootnode['adjacencies'] = adjacencies
      json << rootnode
  
      for artifact in artifacts do
        if relation_search_string
          @outgoing_relationships = ReArtifactRelationship.find(:all,  :order => "relation_type", :conditions => [ relation_search_string, artifact.id])
        else
          @outgoing_relationships = ReArtifactRelationship.find_all_by_source_id(artifact.id)
        end
        @showable_relations = []
        for outgoing_relation in @outgoing_relationships do
          @showable_relations << outgoing_relation if artifacts.include?(ReArtifactProperties.find_by_id(outgoing_relation.sink_id))  
        end
        json << add_artifact(artifact, @showable_relations)
      end
      
    end #if show_tree
   
    json.to_json
  end
  
  def gather_children(artifact)
    children = []
    for child in artifact.children
      next unless (@artifact_choice.include? child.artifact_type.to_s)

      if @chosen_relations_or_string
        @outgoing_relationships = ReArtifactRelationship.find(:all,  :order => "relation_type", :conditions => [  @chosen_relations_or_string, child.id])
      else
        @outgoing_relationships = ReArtifactRelationship.find_all_by_source_id(child.id)
      end
      json_artifact = add_artifact(child, @outgoing_relationships)
      json_artifact['children'] = gather_children(child)
      children << json_artifact
    end
    children
  end

  def add_artifact(artifact, outgoing_relationships)
    type = artifact.artifact_type

    node = {}
    node['id'] = "node_" + artifact.id.to_s
    node['name'] = truncate(artifact.name, :length => TRUNCATE_NAME_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    
    node_data = {}
    node_data['full_name'] = artifact.name
    node_data['description'] = truncate(artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    node_data['priority'] = artifact.priority.to_s
    node_data['created_at'] = artifact.created_at.to_s(:short)
    node_data['author'] = artifact.author.to_s
    node_data['updated_at'] = artifact.updated_at.to_s(:short)
    node_data['user'] = artifact.user.to_s
    node_data['responsibles'] = artifact.responsibles
    node_data['$color'] = ReArtifactColors.get_html_artifact_color_code(@re_artifact_order.index(type))
    node_data['$height'] = 90
    node_data['$angularWidth'] = 13.00
    
    node['data'] = node_data
    
    adjacencies= []
    for relation in outgoing_relationships do
      sink = ReArtifactProperties.find_by_id(relation.sink_id)
      adjacent_node = {}
      adjacent_node['nodeTo'] = "node_" + sink.id.to_s
      #adjacent_node['nodeFrom'] = "node_" + artifact.id.to_s
      edge_data = {}
      edge_data['$color'] = ReArtifactColors.get_html_relation_color_code(relation.relation_type)
      edge_data['$lineWidth'] = 2
      edge_data['$type'] = "arrow" if relation.directed?
      edge_data['$direction'] = [ "node_" + sink.id.to_s, "node_" + artifact.id.to_s ] if relation.directed?
      edge_data['$type'] = "hyperline" unless relation.directed?
      adjacent_node['data'] = edge_data
      adjacencies << adjacent_node
    end
    node['adjacencies'] = adjacencies

    node
  end

  def build_json_according_to_user_choice
    # This method build a new json string in variable @json_netmap which is returned
    # Meanwhile it computes queries for the search for the chosen artifacts and relations.
    # ToDo Refactor this method: The same is done for relationships and artifacts --> outsource!
    @artifact_choice = params[:artifact_clicked]
    @relation_choice = params[:relation_clicked]
    @show_tree = params[:show_tree] == "yes"
    
    # String for condition to find the chosen artifacts
    @chosen_artifacts_or_string = "project_id = ? and (artifact_type = '"
    @chosen_relations_or_string = "source_id = ? and (relation_type = "
    @session_artifacts_chosen = {}
    for artifact in @artifact_choice do
      @chosen_artifacts_or_string += artifact.to_s + "' or artifact_type = '"
    end
    for relation in @relation_choice do
      @chosen_relations_or_string += ReArtifactProperties::RELATION_TYPES[relation.to_sym].to_s + " or relation_type = "
    end
    # remove the last ' or artifact_type = ' and close brackets
    @chosen_artifacts_or_string = @chosen_artifacts_or_string[0, @chosen_artifacts_or_string.length - 21] + ')'
    # remove the last ' or relation_type = ' and close brackets
    @chosen_relations_or_string = @chosen_relations_or_string[0, @chosen_relations_or_string.length - 19] + ')'
    @artifacts = ReArtifactProperties.find(:all, :order => "artifact_type, name", :conditions => [ @chosen_artifacts_or_string , params[:project_id]])
    #@json_netmap = build_json_for_netmap(@artifacts, @chosen_relations_or_string) unless @artifacts.empty?
    @json_netmap = <<JSON
    {
    "name": "ROOT",
    "id": "root",
    "data": {  
      "$alpha": "0.3"  
    },
    "adjacencies": [
      "node6"          
    ],    
    "children": [
        {
            "name": "NODE1",
            "id": "node_1" 
        },
        {
            "name": "NODE2",
            "id": "node_2",
            "children": [
                {
                    "name": "NODE3",
                    "id": "node_3" 
                } 
            ] 
        },
        {
            "name": "NODE4",
            "id": "node_4",
            "children": [
                {
                    "name": "NODE5",
                    "id": "node_5" 
                },
                {
                    "name": "NODE6",
                    "id": "node_6" 
                }                 
            ] 
        }         
      ]
    }
JSON
    @json_netmap = build_json_for_netmap(@artifacts, @chosen_relations_or_string)
    
    render :json => @json_netmap
  end
end
