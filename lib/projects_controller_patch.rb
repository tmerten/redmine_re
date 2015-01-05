require_dependency 'projects_controller'

module ProjectControllerPatch
  def self.included(base)
    base.class_eval do
      alias_method :update_without_requirement_project_name_update, :update unless method_defined?(:update_without_requirement_project_name_update)
      alias_method :update, :update_with_requirement_project_name_update
      
      alias_method :create_without_added_relationtypes, :create unless method_defined?(:create_without_added_relationtypes)
      alias_method :create, :create_with_added_relationtypes
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
  
  def create_with_added_relationtypes
    
    create_without_added_relationtypes
    
    # GET OLD PROJECT NAME
    project = Project.last
    ReRelationtype.new(:project_id => project.id, :relation_type => "parentchild",   :alias_name => "parentchild",  :color => "#0000ff", :is_system_relation => true,  :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "primary_actor", :alias_name => "primary_actor", :color => "#ff99cc", :is_system_relation => true,  :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "actors",        :alias_name => "actors",        :color => "#ff00ff", :is_system_relation => true,  :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "diagram",       :alias_name => "diagram",       :color => "#c0c0c0", :is_system_relation => true,  :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "dependency",    :alias_name => "dependency",    :color => "#339966", :is_system_relation => false, :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "conflict",      :alias_name => "conflict",      :color => "#ff0000", :is_system_relation => false, :is_directed => false, :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "rationale",     :alias_name => "rationale",     :color => "#993300", :is_system_relation => false, :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "refinement",    :alias_name => "refinement",    :color => "#99cc00", :is_system_relation => false, :is_directed => true,  :in_use => true).save
    ReRelationtype.new(:project_id => project.id, :relation_type => "part_of",       :alias_name => "part_of",       :color => "#ffcc00", :is_system_relation => false, :is_directed => true,  :in_use => true).save

  end
  
end

ProjectsController.send(:include, ProjectControllerPatch)