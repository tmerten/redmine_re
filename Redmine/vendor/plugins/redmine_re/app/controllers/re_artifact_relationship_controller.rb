class ReArtifactRelationshipController < ApplicationController
  unloadable

  def prepare_relationships
    @artifact_properties_id = ReArtifactProperties.get_properties_id(params[:original_controller], params[:id])
    @source = ReArtifactProperties.find_by_id(@artifact_properties_id)
    @sink = ReArtifactProperties.find_by_id(params[:sink_id])
    @source.relate_to(@sink, :conflict, false)
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
end
