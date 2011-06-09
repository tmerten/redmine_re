#require File.expand_path('../../test_helper', __FILE__)
#require "#{RAILS_ROOT}/vendor/plugins/redmine_re/app/models/re_bb_data_text.rb" 
require File.dirname(__FILE__) + '/../test_helper'
require 're_building_block'

class ReBuildingBlockTest < ActiveSupport::TestCase
  fixtures :re_building_blocks, :re_bb_data_texts, :re_goals

  def setup
    @simple_bb = ReBbText.new(:name => 'Note_', :artifact_type => 'ReGoal')
    @simple_bb.save
    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
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
    prop = ReArtifactProperties.find_by_id(goal.re_artifact_properties.id)
    params = ReBuildingBlock.find_all_bbs_and_data(prop)
    new_bb = ReBbText.new(:name => 'New', :artifact_type => 'ReGoal')
    new_bb.save
    new_data = ReBbDataText.new(:value => 'New data value', :re_artifact_properties_id => prop.id, :re_bb_text_id => new_bb.id)
    new_data.save
    assert new_bb.re_bb_data_texts.include? new_data
    params_new = ReBuildingBlock.find_all_bbs_and_data(prop)
    assert_equal params.keys.count + 1, params_new.keys.count
    assert !params.has_key?(new_bb)
    assert params_new.has_key?(new_bb)
    assert_equal params_new[new_bb], [new_data]     
  end

end

