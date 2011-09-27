require File.dirname(__FILE__) + '/../test_helper'

class ReArtifactPropertiesTest < ActiveSupport::TestCase
  fixtures :re_artifact_properties, :re_goals

  def setup
    
  end
  
  def test_deletion
    goals = ReGoal.all

    artifacts = []
    goals.each { |goal| artifacts << goal.artifact }
    assert artifacts.count == goals.count, "each goal should have an artifact"

    artifact_name = goals.first.name
    assert ReArtifactProperties.find_by_name( artifact_name ), "artifact should be there"
    goals.first.delete
    assert_raise ActiveRecord::RecordNotFound, "a related artifact should be deleted together with its goal" do
      ReArtifactProperties.find_by_name( artifact_name )
    end

    goal_name = artifacts.last.artifact.name
    assert ReGoal.find_by_name( goal_name ), "goal should be there"
    artifacts.last.delete
    assert_raise ActiveRecord::RecordNotFound, "a related goal should be deleted together with its artifact" do
      ReGoal.find_by_name( goal_name )
    end

  end
end
