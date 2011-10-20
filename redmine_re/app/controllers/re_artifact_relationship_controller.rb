class ReArtifactRelationshipController < RedmineReController
  unloadable
  menu_item :re

  TRUNCATE_NAME_IN_VISUALIZATION_AFTER_CHARS = 18
  TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS = 150
  TRUNCATE_OMISSION = "..."

  include ActionView::Helpers::JavaScriptHelper

  def delete
    @relation = ReArtifactRelationship.find(params[:id])

    unless( @relation.relation_type.eql?(ReArtifactRelationship::RELATION_TYPES[:pch]) )
      @relation.destroy
    end

    @artifact_properties = ReArtifactProperties.find(params[:re_artifact_properties_id])
    @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(params[:re_artifact_properties_id])
    @relationships_outgoing.delete_if { |rel| rel.relation_type.eql?(ReArtifactRelationship::RELATION_TYPES[:pch])}
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(params[:re_artifact_properties_id])
    @relationships_incoming.delete_if { |rel| rel.relation_type.eql?(ReArtifactRelationship::RELATION_TYPES[:pch])}

    render :partial => "relationship_links", :project_id => params[:project_id]
  end

  def autocomplete_sink
    @artifact = ReArtifactProperties.find(params[:id]) unless params[:id].blank?

    query = '%' + params[:sink_name].gsub('%', '\%').gsub('_', '\_').downcase + '%'
    @sinks = ReArtifactProperties.find_all_by_project_id(@project.id, :conditions => ['name like ?', query ])

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

    if relation[:relation_type].eql?(ReArtifactRelationship::RELATION_TYPES[:pch])
      raise ArgumentError, "You are not allowed to create a parentchild relationship!"
    end

    @new_relation = ReArtifactRelationship.new(:source_id => artifact_properties_id, :sink_id => relation[:artifact_id], :relation_type => relation[:relation_type])
    @new_relation.save
    logger.debug("tried saving the following relation (errors: #{@new_relation.errors.size}): " + @new_relation.to_yaml) if logger

    @artifact_properties = ReArtifactProperties.find(artifact_properties_id)
    @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(artifact_properties_id)
    @relationships_outgoing.delete_if { |rel| rel.relation_type.eql?(ReArtifactRelationship::RELATION_TYPES[:pch])}
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(artifact_properties_id)
    @relationships_incoming.delete_if { |rel| rel.relation_type.eql?(ReArtifactRelationship::RELATION_TYPES[:pch])}

    render :partial => "relationship_links", :layout => false, :project_id => params[:project_id]
  end

  def visualization

  end

  def build_json_for_netmap(artifacts, relations)
    json = []

    rootnode = {}
    rootnode['id'] = "node0"
    rootnode['name'] = "Project"

    root_node_data = {}
    root_node_data['$type'] = "none"
    rootnode['data'] = root_node_data

    case @visualization_type
      when "sunburst"
        re_artifact_properties = ReArtifactProperties.find_by_project_id_and_artifact_type(@project.id, "Project")
        children= gather_children(re_artifact_properties)
        rootnode['children'] = children
        json = rootnode
      when "netmap"
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

        artifacts.each do |artifact|
          outgoing_relationships = ReArtifactRelationship.find_all_relations_for_artifact(artifact)
          drawable_relationships = ReArtifactRelationship.find_all_by_source_id_and_relation_type(artifact.id, relations)
          artifact_ids = @artifacts.collect { |a| a.id }
          drawable_relationships.delete_if { |r| ! artifact_ids.include? r.sink_id }
          json << add_artifact(artifact, drawable_relationships, outgoing_relationships)
      end
    else
      json = rootnode
    end
    json.to_json
  end

  def gather_children(artifact)
    children = []
    for child in artifact.children
      next unless (@chosen_artifacts.include? child.artifact_type.to_s)
      outgoing_relationships = ReArtifactRelationship.find_all_relations_for_artifact(child.id)
      drawable_relationships = ReArtifactRelationship.find_all_by_source_id(child.id)
      json_artifact = add_artifact(child, drawable_relationships, outgoing_relationships)
      json_artifact['children'] = gather_children(child)
      children << json_artifact
    end
    children
  end

  def add_artifact(artifact, drawable_relationships, outgoing_relationships)
    type = artifact.artifact_type
    node_settings = ReSetting.get_serialized(type.underscore, @project.id)

    node = {}
    node['id'] = "node_" + artifact.id.to_s
    node['name'] = truncate(artifact.name, :length => TRUNCATE_NAME_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)

    node_data = {}
    node_data['full_name'] = artifact.name
    node_data['description'] = truncate(artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    node_data['created_at'] = artifact.created_at.to_s(:short)
    node_data['author'] = artifact.author.to_s
    node_data['updated_at'] = artifact.updated_at.to_s(:short)
    node_data['user'] = artifact.user.to_s
    node_data['responsibles'] = artifact.responsibles
    node_data['$color'] = "#" + node_settings['color']
    node_data['$height'] = 90                                                    
    node_data['$angularWidth'] = 13.00


    adjacencies= []

    relationship_data = []
    outgoing_relationships.each do |relation|
      artifact_is_source = (artifact == relation.source)
      other_artifact = artifact_is_source ? relation.sink : relation.source
      logger.debug("/////////// RELATION ///////////") if logger
      logger.debug("is_source?" + artifact_is_source.to_s + " source:" + relation.source_id.to_s + " sink:" + relation.sink_id.to_s + " type:" + relation.relation_type.to_s) if logger

      relation_data = {}
      relation_data['id'] = other_artifact.id
      relation_data['full_name'] = other_artifact.name
      relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
      relation_data['created_at'] = other_artifact.created_at.to_s(:short)
      relation_data['author'] = other_artifact.author.to_s
      relation_data['updated_at'] = other_artifact.updated_at.to_s(:short)
      relation_data['user'] = other_artifact.user.to_s
      relation_data['responsibles'] = other_artifact.responsibles
      relation_data['relation_type'] = relation.relation_type
      relation_data['direction'] = artifact_is_source ? 'to':'from'
      relationship_data << relation_data
    end

    node_data['relationship_data'] = relationship_data 
    node['data'] = node_data

    drawable_relationships.each do |relation|
      sink = ReArtifactProperties.find_by_id(relation.sink_id)

      directed = ReArtifactRelationship.find_by_source_id_and_sink_id(relation.sink_id, relation.source.id).nil?
      relation_settings = ReSetting.get_serialized(relation.relation_type, @project.id)

      adjacent_node = {}

      logger.debug("Relation Settings: " + relation_settings.to_yaml )

      adjacent_node['nodeTo'] = "node_" + sink.id.to_s
      #adjacent_node['nodeFrom'] = "node_" + artifact.id.to_s
      edge_data = {}
      edge_data['$color'] = "#" + relation_settings['color']
      edge_data['$lineWidth'] = 2
      edge_data['$type'] = "arrow" if directed
      edge_data['$direction'] = [ "node_" + sink.id.to_s, "node_" + artifact.id.to_s ] if directed
      edge_data['$type'] = "hyperline" unless directed
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
    @visualization_type = params[:visualization_type]

    # String for condition to find the chosen artifacts

    @chosen_artifacts = []
    @chosen_relations = []
    @json_netmap = []

    unless params[:artifact_filter].blank? || params[:relation_filter].blank?
      params[:artifact_filter].each { |a| @chosen_artifacts << a.to_s.camelize }
      params[:relation_filter].each { |r| @chosen_relations << ReArtifactRelationship::RELATION_TYPES[r.to_sym] }

      @artifacts = ReArtifactProperties.find_all_by_project_id_and_artifact_type(@project.id, @chosen_artifacts, :order => "artifact_type, name")
      @json_netmap = build_json_for_netmap(@artifacts, @chosen_relations)
    end

    render :json => @json_netmap
  end
end
