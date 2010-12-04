class ReArtifactRelationshipController < ApplicationController
  unloadable

  

  def prepare_relationships
    @artifact_properties_id = ReArtifactProperties.get_properties_id(params[:original_controller], params[:id])
    if params[:sink_id] != ""
      @source = ReArtifactProperties.find_by_id(@artifact_properties_id)
      @sink = ReArtifactProperties.find_by_id(params[:sink_id])
      @source.relate_to(@sink, :conflict, false)
    end
    @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(@artifact_properties_id)
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(@artifact_properties_id)
    render :partial => "relationship_links", :layout => false, :project_id => params[:project_id]
  end

  def index
  end

  def show
  end

  def new
  end

  def edit
  end



  def visualization
    # Building JSON-Tree for Netmap-Visualization. As the JIT-Sunburst-Visualization
    # is usually build for trees, we have to add a dummy root element which isn't shown
    # and insert all the artifacts we are interested in as children of this very root node
    @artifacts = ReArtifactProperties.find_all_by_project_id(params[:project_id], :order => "artifact_type, name")
    @json_netmap = '[
      {
        "id": "node0",
        "name": "",
        "data": {
          "$type": "none"
        },
        "adjacencies": ['
    @json_netmap += add_artifacts_as_children_of_root(@artifacts)
    @json_netmap += ']},'
    for artifact in @artifacts do
      @outgoing_relationships = ReArtifactRelationship.find_all_by_source_id(artifact.id)
      @json_netmap += add_artifact(artifact, @outgoing_relationships)
    end
    # remove last comma
    @json_netmap = @json_netmap[0, @json_netmap.length - 1] + ']'
  end



  def add_artifacts_as_children_of_root(artifacts)
    @json_artifacts_as_children_of_root = ""
    for artifact in artifacts do
      @json_artifacts_as_children_of_root += '{ "nodeTo": "' + artifact.artifact_type.to_s + artifact.artifact_id.to_s + '", "data": {' + "'$type': 'none'} },"
    end
    @json_artifacts_as_children_of_root = @json_artifacts_as_children_of_root[0, @json_artifacts_as_children_of_root.length - 1]
  end


  def add_artifact(artifact, outgoing_relationships)
    @json_artifact = '{ "id": "' + artifact.artifact_type.to_s + artifact.artifact_id.to_s + '",
                        "name": "' + artifact.name + '",
                        "data": { "$color": "' + ReArtifactProperties::ARTIFACT_COLOURS[artifact.artifact_type.to_sym] + '",
                                  "$height": 70},
                        "adjacencies": [ '
    for relation in outgoing_relationships do
      @sink = ReArtifactProperties.find_by_id(relation.sink_id)
      @json_artifact += '{ "nodeTo": "' + @sink.artifact_type.to_s + @sink.artifact_id.to_s + '",
                           "data": {
                                     "$color": "' + ReArtifactRelationship::RELATION_COLOURS[relation.relation_type.to_i].to_s + '",
                                     "$lineWidth": 2
                                   }
                         },'
    end
    # remove last comma
    @json_artifact = @json_artifact[0, @json_artifact.length - 1]
    @json_artifact += ']},'
  end

end
