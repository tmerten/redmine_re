require File.dirname(__FILE__) + '/../test_helper'

class ReArtifactPropertiesTest < ActiveSupport::TestCase
  fixtures :projects, :re_artifact_properties

  def setup
    @ecookbook = Project.find(1)
    @changed_name = "Name Property Changed"
    @changed_name2 = "Name Property Changed Again"
    
    User.current = nil
  end
  
  def test_pseudo_project_artifact
    
    @ecobook.save
    assert_nil project_properties, "Project artifact should not be created if the project did not change"
    
    @ecobook.name = @changed_name
    @ecobook.save
    project_properties = ReArtifactProperties.find_by_artifact_type "Project"
    
    # changed project name and saved (new project properties)
    assert_not_nil project_properties, "Project artifact should be created if the project has changed"
    assert_equal @changed_name, project_properties.name, "Project artifact should have the same name as the project"
    
    project_properties_id = project_properties.id
    @ecobook.name = @changed_name2
    @ecobook.save
    project_properties = ReArtifactProperties.find_by_artifact_type "Project"

    assert_not_nil project_properties, "Project artifact should be created if the project has changed"
    assert_equal project_properties_id, project_properties.id, "The existing project artifact should be updated"
    assert_equal @changed_name2, project_properties.name, "Project artifact should have the same name as the project"
  end
end
