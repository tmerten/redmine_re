#require File.expand_path('../../test_helper', __FILE__)
#require "#{RAILS_ROOT}/vendor/plugins/redmine_re/app/models/re_bb_data_text.rb" 
require File.dirname(__FILE__) + '/../test_helper'
require 're_building_block'

class ReBuildingBlockTest < ActiveSupport::TestCase
  fixtures :re_bb_data_texts, :re_goals

  def setup
    @simple_bb = ReBbText.new(:name => 'Note_', :artifact_type => 'ReGoal')
    @simple_bb.save
    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
    logger.info("Example how to call the logger: #{@complex_bb_text.inspect} ")
  end
  
  def test_if_artifact_type_is_not_overrideable
    type = @simple_bb.artifact_type
    @simple_bb.artifact_type = 'ReTask'
    @simple_bb.save
    assert_equal @simple_bb.artifact_type, type
  end

  def test_if_right_bbs_are_delivered_for_artifact
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    #logger.info("Example how to call the logger: ")
    prop = goal.re_artifact_properties
    params = ReBuildingBlock.find_all_bbs_and_data(prop)
    new_bb = ReBbText.new(:name => 'New', :artifact_type => 'ReGoal')
    new_bb.save
    new_data = ReBbDataText.new(:value => 'New data value', :re_artifact_properties_id => prop.id, :re_bb_text_id => new_bb.id)
    new_data.save
    assert new_bb.re_bb_data_texts.include? new_data
    params_new = ReBuildingBlock.find_all_bbs_and_data(prop)
    assert_equal params.keys.count + 1, params_new.keys.count
    assert ! params.has_key?(new_bb)
    assert params_new.has_key?(new_bb)
    assert_equal params_new[new_bb], [new_data]     
  end
  
  def test_if_mandatory_validation_error_is_added_correcty
    error_hash = {}
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    new_bb = ReBbText.new(:name => 'New', :artifact_type => 'ReGoal', :mandatory => true)
    new_bb.save
    # Assert that error is added if no data is there at all
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert error_hash[new_bb.id][:general].include?(I18n.t(:re_bb_mandatory, :bb_name => new_bb.name))
    # Assert that error is not added if no data is there at all but bb is not mandatory
    new_bb.mandatory = false
    new_bb.save
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_mandatory, :bb_name => new_bb.name))
    # Assert that error is added if bb is mandatory and the value of data is ''
    new_bb.mandatory = true
    new_bb.save
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
    new_bb = ReBbText.new(:name => 'New', :artifact_type => 'ReGoal', :min_length => 10)
    new_bb.save
    new_data = ReBbDataText.new(:value => 'Short', :re_artifact_properties_id => goal.re_artifact_properties.id, :re_bb_text_id => new_bb.id)
    new_data.save
    message = 'Already existing error'
    error_hash[new_bb.id] = {new_data.id => [message]}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash)
    assert error_hash[new_bb.id][new_data.id].include?(I18n.t(:re_bb_too_short, :bb_name => new_bb.name, :min_length => new_bb.min_length))
    assert error_hash[new_bb.id][new_data.id].include?(message)  
  end
  

end

