require File.dirname(__FILE__) + '/../test_helper'

class RequirementsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  test "Check if relations during move functions a correct" do
    
    # Fixtures provides the following tree (Project id 5)
    #
    # testartifact_relation_move_root
    #   testartifact_relation_move_l1_1
    #     testartifact_relation_move_l2_1
    #     testartifact_relation_move_l2_2
    #     testartifact_relation_move_l2_3
    #   testartifact_relation_move_l1_2
    
    # Validation tree structure
    project = ReArtifactProperties.find(ActiveRecord::Fixtures.identify(:testartifact_relation_move_root))
    assert_not_nil project, "Test project was not found"
    assert project.id > 0, "Project id is not correct"
    n = ReArtifactRelationship.where(:source_id => project.artifact_id.to_s).count
    assert_equal 2, n, "Project tree structure is not correct"
    assert_equal ActiveRecord::Fixtures.identify(:testartifact_relation_move_l1_1), project.children.first().id
    assert_equal ActiveRecord::Fixtures.identify(:testartifact_relation_move_l1_2), project.children.last().id
    
    artifact_1_1 = ReArtifactProperties.find(ActiveRecord::Fixtures.identify(:testartifact_relation_move_l1_1))
    assert_not_nil artifact_1_1, "Artifact 1_1 was not found"
    assert artifact_1_1.id > 0, "Artifact 1_1 id is not correct"
    n = ReArtifactRelationship.where(:source_id => artifact_1_1.artifact_id.to_s).count
    assert_equal 3, n, "Project tree structure is not correct"
    
    # Simulate a POST response with the given HTTP parameters. delegate_tree_drop
    post("requirements#delegate_tree_drop",  
      { :sibling_id => ActiveRecord::Fixtures.identify(:testartifact_relation_move_l2_2), 
        :moved_artifact_id => ActiveRecord::Fixtures.identify(:testartifact_relation_move_l2_3), 
        :insert_position => "inside" 
      }
    )
    
    # New Tree:
    # testartifact_relation_move_root
    #   testartifact_relation_move_l1_1
    #     testartifact_relation_move_l2_1
    #     testartifact_relation_move_l2_2
    #       testartifact_relation_move_l2_3
    #   testartifact_relation_move_l1_2
    n = ReArtifactRelationship.where(:source_id => artifact_1_1.artifact_id.to_s).count
    assert_equal 2, n, "Project tree structure is not correct"
    
    n = ReArtifactRelationship.where(:source_id => ActiveRecord::Fixtures.identify(:testartifact_relation_move_l2_2).to_s).count
    assert_equal 1, n, "Project tree structure is not correct"
    
  end
  
end
