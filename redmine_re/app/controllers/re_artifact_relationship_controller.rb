class ReArtifactRelationshipController < RedmineReController
  unloadable
  menu_item :re
  
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
      list << '<li id="'
      list << sink.id.to_s
      list << '">'
      list << sink.name
      list << '</li>'
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
    @json_for_netmap = '[
      {
        "id": "node0",
        "name": "",
        "data": {
          "$type": "none"
        },
        "adjacencies": ['
    @json_for_netmap += add_artifacts_as_children_of_root(artifacts)
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
      @json_for_netmap += add_artifact(artifact, @showable_relations)
    end
    # remove last comma
    @json_for_netmap = remove_last_comma_and_close(@json_for_netmap, ']')
  end

  def add_artifacts_as_children_of_root(artifacts)
    @json_artifacts_as_children_of_root = ""
    for artifact in artifacts do
      @json_artifacts_as_children_of_root += '{ "nodeTo": "' + artifact.artifact_type.to_s + artifact.artifact_id.to_s + '", "data": {"$type": "none"} },'
    end
    @json_artifacts_as_children_of_root = remove_last_comma_and_close(@json_artifacts_as_children_of_root, ']},')
  end

  def add_artifact(artifact, outgoing_relationships)
  	type = artifact.artifact_type
    @json_artifact = '{ "id": "' + escape_javascript(type.to_s) + escape_javascript(artifact.artifact_id.to_s) + '",
                        "name": "' + escape_javascript(artifact.name) + '",
                        "data": { "$color": "' + ReArtifactColors.get_html_artifact_color_code(@re_artifact_order.index(type)) + '",
                                  "$height": 90},
                        "adjacencies": [ '
    for relation in outgoing_relationships do
      @sink = ReArtifactProperties.find_by_id(relation.sink_id)
      @json_artifact += '{ "nodeTo": "' + escape_javascript(@sink.artifact_type.to_s) + escape_javascript(@sink.artifact_id.to_s) + '",
                           "data": {
                                     "$color": "' + ReArtifactColors.get_html_relation_color_code(relation.relation_type) + '",
                                     "$lineWidth": 2'
			@json_artifact += ', "$type": "arrow",' if relation.directed?                                     
			@json_artifact += '		}
                         },'
    end
    # "$type": "arrow"
    # "$type": "line"
    @json_artifact = remove_last_comma_and_close(@json_artifact, ']},')
  end

  def remove_last_comma_and_close(json_string, closing_string)
    # This method removes the last character of a given string and adds another string at the end
    # Used to remove the last comma and to close the current json-structure
    json_string = json_string[0, json_string.length - 1] + closing_string
  end

  def build_json_according_to_user_choice
    @size = '600px' || params[:visualization_size]
    
    
    # This method build a new json string in variable @json_netmap which is returned
    # Meanwhile it computes queries for the search for the chosen artifacts and relations.
    # ToDo Refactor this method: The same is done for relationships and artifacts --> outsource!
    @artifact_choice = params[:artifact_clicked]
    @relation_choice = params[:relation_clicked]
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
    @json_netmap = build_json_for_netmap(@artifacts, @chosen_relations_or_string) unless @artifacts.empty?
    render :json => @json_netmap
  end
end
