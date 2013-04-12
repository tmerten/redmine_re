require_dependency 'projects_controller'
module ProjectControllerPatch
  def self.included(base)
    base.class_eval do
      alias_method :update_without_requirement_project_name_update, :update unless method_defined?(:update_without_requirement_project_name_update)
      alias_method :update, :update_with_requirement_project_name_update
    end
  end
  
  def update_with_requirement_project_name_update
    
    # GET OLD PROJECT NAME
    project = Project.find_by_identifier(params[:id])
    
    # Perform update action
    update_without_requirement_project_name_update
    
    # Update project name
    artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", project.id)
    
    if !artifact.nil?
      #restrict file name length to allowed length in artifact name
      name = project[:name]      
      if name.length < 3 
        name = name+" Project" 
      end
      if name.length > 50
        name = name[0..49]
      end       
      artifact.name = project[:name]
      artifact.save
    end
    
  end
end

ProjectsController.send(:include, ProjectControllerPatch)
