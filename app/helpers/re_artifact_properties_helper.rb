module ReArtifactPropertiesHelper
  #include ApplicationHelper

  def artifact_heading(artifact)
    h("#{rendered_artifact_type(artifact.artifact_type)} ##{artifact.id} ")
  end
end
