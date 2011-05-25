require File.expand_path('../../test_helper', __FILE__)

class ReBuildingBlockTest < ActiveSupport::TestCase
#  fixtures :re_building_blocks
#  fixtures :re_bb_data_texts
 # fixtures :re_goals

  def setup
    @simpel_bb = ReBuildingBlock.new(:name => 'Note', :artifact_type => 'ReGoal', :type => 'ReBbText')
    @simpel_bb.save
    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
  end
  
  def test_if_artifact_type_is_not_overrideable
    type = @simpel_bb.artifact_type
    @simpel_bb.artifact_type = 'ReTask'
    @simpel_bb.save
    assert_equal @simpel_bb.artifact_type, type
  end  

  def test_if_right_bbs_are_delivered_for_artifact
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    prop = ReArtifactProperties.find_by_id(goal.re_artifact_properties.id)
    params = ReBuildingBlock.find_all_bbs_and_data(prop)
    new_bb = ReBbText.new(:name => 'New', :artifact_type => 'ReGoal')
    new_bb.save
    new_data = ReBbDataText.new(:value => 'New data value', :re_artifact_properties_id => prop.id, :re_bb_text_id => new_bb.id)
    new_data.save
    params_new = ReBuildingBlock.find_all_bbs_and_data(prop)
    assert_equal params.keys.count + 1, params_new.keys.count
    assert !params.has_key?(new_bb)
    assert params_new.has_key?(new_bb)
    assert_equal params_new[new_bb], [new_data]     
  end

end

