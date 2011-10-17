require File.dirname(__FILE__) + '/../test_helper'

class ReBbArtifactSelectionTest < ActiveSupport::TestCase

  fixtures :re_building_blocks, :re_goals, :re_tasks, :re_artifact_relationships

  def setup
    @project = Project.find(:first)
    @artifact_selection_goals = ReBbArtifactSelection.new
    params = {:re_building_block => {:name => 'Select Goals', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal'], :referred_relationship_types => ['conflict'], :embedding_type => 'one_line'}}
    @artifact_selection_goals = save_building_block_completely(@artifact_selection_goals, params) 
 
    @artifact_selection_goals_or_tasks = ReBbArtifactSelection.new()
    params = {:re_building_block => {:name => 'Select Goals or Tasks', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal', 'ReTask'], :referred_relationship_types => ['conflict'], :embedding_type => 'none', :multiple_values => false, :mandatory => false}}
    @artifact_selection_goals_or_tasks = save_building_block_completely(@artifact_selection_goals_or_tasks, params) 
    
    @task_prop = ReArtifactProperties.find_by_id(Fixtures.identify(:art_task_test_vocabulary))
    @goal_prop = ReArtifactProperties.find_by_id(Fixtures.identify(:art_goal_usability))
    @relationship = ReArtifactRelationship.find(:first, :conditions => {:source_id => @task_prop.id, :sink_id => @goal_prop.id, :relation_type => 'conflict'})
  end 
  
  
  def test_if_relationships_are_created_correctly_when_data_is_saved
    # if relationship of the same type between two artifacts already exists, 
    # check if no new one is created but the old one is reused
    relation_count = ReArtifactRelationship.find(:all).count
    data_hash = {@artifact_selection_goals.id => {'no_id' => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    assert_equal relation_count, ReArtifactRelationship.find(:all).count
    assert_equal @relationship.id, @artifact_selection_goals.re_bb_data_artifact_selections.first.re_artifact_relationship_id
    # test if data is deleted when relationship is deleted
    @relationship.destroy
    assert_equal @artifact_selection_goals.find_my_data(@task_prop).count, 0
    # if no relationship of the same type between the two artifacts exists,
    # check if a new one is created by save_data
    assert ReArtifactRelationship.find(:first, :conditions => {:source_id => @task_prop.id, :sink_id => @goal_prop.id, :relation_type => 'conflict'}) == nil 
    relation_count = ReArtifactRelationship.find(:all).count
    data_hash = {@artifact_selection_goals.id => {'no_id' => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash) 
    assert_equal relation_count + 1, ReArtifactRelationship.find(:all).count
    assert ReArtifactRelationship.find(:first, :conditions => {:source_id => @task_prop.id, :sink_id => @goal_prop.id, :relation_type => 'conflict'}) != nil    
  end
  
  
  def test_if_data_is_deleted_if_no_artifact_is_choosen_and_bb_allows_single_values
    # Save data for a bb with single data only and then deliver data with no artifact choosen
    data_hash = {@artifact_selection_goals_or_tasks.id => {'no_id' => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    datum = @artifact_selection_goals_or_tasks.find_my_data(@task_prop).first
    assert_equal @artifact_selection_goals_or_tasks.find_my_data(@task_prop).count, 1
    # Update datum without delivering a new id
    data_hash = {@artifact_selection_goals_or_tasks.id => {datum.id => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => ''}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    assert_equal @artifact_selection_goals_or_tasks.find_my_data(@task_prop).count, 0
    # Now try to do the same with a bb where multiple values are allowed and check
    # that the data is not deleted
    params = {:re_building_block => {:name => 'Select Goals or Tasks', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal', 'ReTask'], :referred_relationship_types => ['conflict'], :embedding_type => 'none', :multiple_values => true, :mandatory => false}}
    @artifact_selection_goals_or_tasks = save_building_block_completely(@artifact_selection_goals_or_tasks, params) 
    data_hash = {@artifact_selection_goals_or_tasks.id => {'no_id' => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    datum = @artifact_selection_goals_or_tasks.find_my_data(@task_prop).first
    assert_equal @artifact_selection_goals_or_tasks.find_my_data(@task_prop).count, 1
    # Update datum without delivering a new id
    data_hash = {@artifact_selection_goals_or_tasks.id => {datum.id => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => ''}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    assert_equal @artifact_selection_goals_or_tasks.find_my_data(@task_prop).count, 1 
  end
  
  
  def test_validation_of_wrong_type_of_selected_artifact_or_relation_after_config_change
    # Test if no validation error occures if artifact type and relationshhip type match
    # the configuration of the building block.
    data_hash = {@artifact_selection_goals_or_tasks.id => {'no_id' => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    datum = @artifact_selection_goals_or_tasks.find_my_data(@task_prop).first
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert error_hash[@artifact_selection_goals_or_tasks.id] == nil
    # Changing configurarion of building block so that created relation does not match any longer
    params = {:re_building_block => {:name => 'Select Goals or Tasks', :artifact_type => 'ReTask', :referred_artifact_types => ['ReTask'], :referred_relationship_types => ['refinement'], :embedding_type => 'none', :multiple_values => false, :mandatory => false}}
    @artifact_selection_goals_or_tasks = save_building_block_completely(@artifact_selection_goals_or_tasks, params) 
    # Assert that corresponding error messages are generated
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert error_hash[@artifact_selection_goals_or_tasks.id][datum.id].include?(I18n.t(:re_bb_artifact_type_does_not_match, :type => I18n.t(:ReGoal)))
    assert error_hash[@artifact_selection_goals_or_tasks.id][datum.id].include?(I18n.t(:re_bb_relation_type_does_not_match, :type => I18n.t(:re_conflict)))
    # Updating relationship so that it matches the config again
    data_hash = {@artifact_selection_goals_or_tasks.id => {datum.id => {:artifact_type => 'ReTask', :relation_type => 'refinement', :related_artifact_id => @task_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    # Asserting that no error messages concerning wrong types are generated
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert error_hash[@artifact_selection_goals_or_tasks.id] == nil    
  end
  
  
  def test_if_array_with_seleced_attributes_is_deleted_if_embedding_type_is_changed_from_attributes
    # Set 'selected attributes' array to something
    params = {:re_building_block => {:name => 'Select Goals or Tasks', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal', 'ReTask'], :referred_relationship_types => ['conflict'], :embedding_type => 'attributes', :selected_attributes => ['name', 'description'], :multiple_values => false, :mandatory => false}}
    @artifact_selection_goals = save_building_block_completely(@artifact_selection_goals, params) 
    assert @artifact_selection_goals.selected_attributes == ['name', 'description']
    # Change embedding type to anything else but 'attributes' and check if 
    # 'selected attributes' is deleted
    params = {:re_building_block => {:name => 'Select Goals or Tasks', :artifact_type => 'ReTask', :referred_artifact_types => ['ReGoal', 'ReTask'], :referred_relationship_types => ['conflict'], :embedding_type => 'none', :multiple_values => false, :mandatory => false}}
    @artifact_selection_goals = save_building_block_completely(@artifact_selection_goals, params) 
    assert @artifact_selection_goals.selected_attributes == nil
  end
  
  
  def test_validation_of_changed_referred_artifact
    # Use established relation to artifact goal for the data of the artifact selection building block
    data_hash = {@artifact_selection_goals.id => {'no_id' => {:artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    datum = @artifact_selection_goals.find_my_data(@task_prop).first
    # Test if no error message concerning the actuality of the relation occures
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_out_of_date, :bb_name => I18n.t(@artifact_selection_goals.name)))
    # Update referred artifact and test if error message still not present now,
    # as building block is not configured to show these messages
    assert @artifact_selection_goals.indicate_changes == false
    sleep 2
    @goal_prop.description = 'New description.'
    assert @goal_prop.save
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_out_of_date, :bb_name => I18n.t(@artifact_selection_goals.name)))
    # Change config of building block so that out of date message is shown 
    params = {:re_building_block => {:indicate_changes => true}}
    @artifact_selection_goals = save_building_block_completely(@artifact_selection_goals, params) 
    assert @artifact_selection_goals.indicate_changes == true
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash)
    assert extract_error_messages(error_hash).include?(I18n.t(:re_bb_out_of_date, :bb_name => @artifact_selection_goals.name))
    # Confirm that relation and referred artifact are still valid by setting the confirm
    # parameter
    data_hash = {@artifact_selection_goals.id => {datum.id => {:confirm_checked => true, :artifact_type => 'ReGoal', :relation_type => 'conflict', :related_artifact_id => @goal_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, data_hash)
    # Test if no error message concerning the actuality of the relation occures again
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_out_of_date, :bb_name => I18n.t(@artifact_selection_goals.name)))
  end
  
  
end
