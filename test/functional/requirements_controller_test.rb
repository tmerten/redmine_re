require File.dirname(__FILE__) + '/../test_helper'
load "#{Rails.root}/plugins/redmine_re/db/seeds_requirements_controller_functional.rb"

class RequirementsControllerTest < ActionController::TestCase
    ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
    [:users])
  # Replace this with your real tests.

  def setup
    #User.current = nil
    #@request.session[:user_id] = 2 # admin
  end
  
  def test_truth
    assert true
  end
  
  test "Check if relations during move functions a correct" do
    
    @request.session[:user_id] = 1
    
    # seeds.rb provides the following tree (Project id 1)
    # (Count of relations: 10)
    # Testprojekt (ID 1; Project)
    #    Chapter 1 (ID 2; Section)
    #       Requirement 1.1 (ID 4; Requirement)
    #       Requirement 1.2 (ID 5; Requirement)
    #       Requirement 1.3 (ID 6; Requirement)
    #    Chapter 2 (ID 3; Section)
    #       Goal 2.1 (ID 7; Goal)
    #       Goal 2.2 (ID 8; Goal)
    #    Chapter 3 (ID 9; Section)
    #       Userprofil 3.1 (ID 10; Userprofil)
    #       Userprofil 3.2 (ID 11; Userprofil)
    
    n = ReArtifactRelationship.where(:source_id => "1").count
    assert_equal 3, n, "Project tree structure is not correct (1)"
    
    n = ReArtifactRelationship.where(:source_id => "2").count
    assert_equal 3, n, "Project tree structure is not correct (2)"
    
    n = ReArtifactRelationship.where(:source_id => "3").count
    assert_equal 2, n, "Project tree structure is not correct (3)"
    
    n = ReArtifactRelationship.where(:source_id => "9").count
    assert_equal 2, n, "Project tree structure is not correct (4)"
    
    n = ReArtifactRelationship.count
    assert_equal 10, n, "Project tree structure is not correct (5)"
    
    # Simulate a POST response with the given HTTP parameters. 
    post("delegate_tree_drop", 
      { :sibling_id => 8, 
        :id => 11, # Artifact_moved_id
        :position => "inside" 
      }
    )
    
    #New Tree:
    # Testprojekt (ID 1; Project)
    #    Chapter 1 (ID 2; Section)
    #       Requirement 1.1 (ID 4; Requirement)
    #       Requirement 1.2 (ID 5; Requirement)
    #       Requirement 1.3 (ID 6; Requirement)
    #    Chapter 2 (ID 3; Section)
    #       Goal 2.1 (ID 7; Goal)
    #       Goal 2.2 (ID 8; Goal)
    #          Userprofil 3.2 (ID 11; Userprofil)
    #    Chapter 3 (ID 9; Section)
    #       Userprofil 3.1 (ID 10; Userprofil)
    #       Userprofil 3.2 (ID 11; Userprofil)
    
    
    n = ReArtifactRelationship.where(:source_id => "8").count
    assert_equal 1, n, "Project tree structure is not correct (6)"
    
    n = ReArtifactRelationship.count
    assert_equal 10, n, "Project tree structure is not correct (7)"

  end
  
end
