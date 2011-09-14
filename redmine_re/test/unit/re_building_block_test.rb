#require File.expand_path('../../test_helper', __FILE__)
#require "#{RAILS_ROOT}/vendor/plugins/redmine_re/app/models/re_bb_data_text.rb" 
require File.dirname(__FILE__) + '/../test_helper'
require 're_building_block'

class ReBuildingBlockTest < ActiveSupport::TestCase
  fixtures  :re_building_blocks, :re_bb_data_texts, :re_goals

  def setup
    @simple_bb = ReBbText.new
    params = {:re_building_block => {:name => 'Note_', :artifact_type => 'ReGoal'}}
    @simple_bb = save_building_block_completely(@simple_bb, params)

    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
    @task_prop = ReTask.find_by_id(Fixtures.identify(:task_test_vocabulary)).re_artifact_properties
  end
  
  def test_if_artifact_type_is_not_overrideable
    type = @simple_bb.artifact_type
    params = {:re_building_block => {:artifact_type => 'ReTask'}}
    @simple_bb = save_building_block_completely(@simple_bb, params)
    assert_equal @simple_bb.artifact_type, type
  end

  def test_if_right_bbs_are_delivered_for_artifact
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    prop = goal.re_artifact_properties
    params_old = ReBuildingBlock.find_all_bbs_and_data(prop)
    new_bb = ReBbText.new
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal'}}
    new_bb = save_building_block_completely(new_bb, params)
    new_data = ReBbDataText.new(:value => 'New data value', :re_artifact_properties_id => prop.id, :re_bb_text_id => new_bb.id)
    new_data.save
    assert new_bb.re_bb_data_texts.include? new_data
    params_new = ReBuildingBlock.find_all_bbs_and_data(prop)
    assert_equal params_old.keys.count + 1, params_new.keys.count
    assert ! params_old.has_key?(new_bb)
    assert params_new.has_key?(new_bb)
    assert_equal params_new[new_bb], [new_data]     
  end
  
  def test_if_mandatory_validation_error_is_added_correcty
    error_hash = {}
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    new_bb = ReBbText.new
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :mandatory => true}}
    new_bb = save_building_block_completely(new_bb, params)
    # Assert that error is added if no data is there at all
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert error_hash[new_bb.id][:general].include?(I18n.t(:re_bb_mandatory, :bb_name => new_bb.name))
    # Assert that error is not added if no data is there at all but bb is not mandatory
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :mandatory => false}}
    new_bb = save_building_block_completely(new_bb, params)
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_mandatory, :bb_name => new_bb.name))
    # Assert that error is added if bb is mandatory and the value of data is ''
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :mandatory => true}}
    new_bb = save_building_block_completely(new_bb, params)
    new_data = ReBbDataText.new(:value => '', :re_artifact_properties_id => goal.re_artifact_properties.id, :re_bb_text_id => new_bb.id)
    new_data.save
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert error_hash[new_bb.id][:general].include?(I18n.t(:re_bb_mandatory, :bb_name => new_bb.name))
    # Assert that no error is added for mandatory bb if data given and not ''
    new_data.value = 'Some data'
    new_data.save
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_mandatory, :bb_name => new_bb.name))
  end
  
 
  def test_if_errors_are_added_and_do_not_overwrite
    error_hash = {}
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    # Assert that error is added if data value is longer than maximal length
    new_bb = ReBbText.new
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :min_length => 10}}
    new_bb = save_building_block_completely(new_bb, params)
    new_data = ReBbDataText.new(:value => 'Short', :re_artifact_properties_id => goal.re_artifact_properties.id, :re_bb_text_id => new_bb.id)
    new_data.save
    message = 'Already existing error'
    error_hash[new_bb.id] = {new_data.id => [message]}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert error_hash[new_bb.id][new_data.id].include?(I18n.t(:re_bb_too_short, :bb_name => new_bb.name, :min_length => new_bb.min_length))
    assert error_hash[new_bb.id][new_data.id].include?(message)  
  end
  
  def test_validation_of_multiple_values
    # Create building block that allows multiple data. Then create two data-items.
    # Check that no error message occures
    my_bb = ReBbSelection.new()
    params = {:re_building_block => {:name => 'Multiple', :artifact_type => 'ReTask', :default_value => 'Eins', :multiple_values => true}, :options => 'Zwei, Drei'}
    my_bb = save_building_block_completely(my_bb, params) 
    option_1 = my_bb.re_bb_option_selections.first
    option_2 = my_bb.re_bb_option_selections.last
    params = {my_bb.id => {'no_id' => {:re_bb_selection_id => my_bb.id, :re_bb_option_selection_id => option_1.id, :re_artifact_properties_id => @task_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, params)
    params = {my_bb.id => {'no_id' => {:re_bb_selection_id => my_bb.id, :re_bb_option_selection_id => option_2.id, :re_artifact_properties_id => @task_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, params)
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_no_multiple_data_allowed, :bb_name => my_bb.name)) 
    # Change configuration so that building block allows single data  only
    # Test if error message occures.
    params = {:re_building_block => {:name => 'NotMultiple', :artifact_type => 'ReTask', :default_value => 'Eins', :multiple_values => false}, :options => ''}
    my_bb = save_building_block_completely(my_bb, params)  
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash)
    assert extract_error_messages(error_hash).include?(I18n.t(:re_bb_no_multiple_data_allowed, :bb_name => my_bb.name)) 
    # Now delete one datum and check if error message is gone.
    datum = my_bb.re_bb_data_selections.first
    assert datum.destroy    
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_no_multiple_data_allowed, :bb_name => my_bb.name)) 
  end
  

end

