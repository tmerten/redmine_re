class RequirementsController < RedmineReController
  unloadable
  menu_item :re

  def index
    @html_tree = create_tree
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    
    if @project_artifact.nil?
      redirect_to :action => "setup", :project_id => @project.id
    end
  end

  def setup
    @project = Project.find(params[:project_id])
    
    @project_artifact = nil
    @project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", @project.id)
    if @project_artifact.nil?
      @project_artifact = ReArtifactProperties.new 
      @project_artifact.project = @project
      @project_artifact.created_by = User.first # is there a better solution?
      @project_artifact.updated_by = User.first # actually this is not editable anyway
      @project_artifact.artifact_type = "Project"
      @project_artifact.artifact_id = @project.id
      @project_artifact.description = @project.description
      @project_artifact.priority = 50
      @project_artifact.name = @project.name
      @project_artifact.save
    end
  end
  
end