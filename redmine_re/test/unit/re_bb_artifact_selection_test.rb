require File.dirname(__FILE__) + '/../test_helper'

class ReBbArtifactSelectionTest < ActiveSupport::TestCase

  fixtures :re_building_blocks, :re_goals, :re_tasks

  def setup
    @artifact_selection_goals = ReBbArtifactSelection.new(:name => 'Select Goals', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal'], :referred_relationship_types => ['conflict'], :embedding_type => 'one_line')
    @artifact_selection_goals.save
    @artifact_selection_goals_or_tasks = ReBbArtifactSelection.new(:name => 'Select Goals or Tasks', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal', 'ReTask'], :referred_relationship_types => ['conflict'], :embedding_type => 'none')
    @artifact_selection_goals_or_tasks.save
    @task_prop = ReTask.find_by_id(Fixtures.identify(:task_test_vocabulary)).re_artifact_properties
    @goal_prop = ReGoal.find_by_id(Fixtures.identify(:goal_usability)).re_artifact_properties
  end 
  
  
  def test_truth
    assert true
  end
end
