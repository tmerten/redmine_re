require File.expand_path('../../test_helper', __FILE__)

class ReBbTextTest < ActiveSupport::TestCase
#  fixtures :re_building_blocks
#  fixtures :re_bb_data_texts
 # fixtures :re_goals

  def setup
    @simple_bb = ReBuildingBlock.new(:name => 'Note', :artifact_type => 'ReGoal', :type => 'ReBbText')
    @simple_bb.save
    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
  end
  
  def test_if_default_value_outside_min_max_is_prohibited
    @simple_bb.default_value = 'ReTask'
    @simple_bb.min_length = 10
    assert_false @simpel_bb.save
    @simple_bb.min_length = 5
    assert_true @simpel_bb.save
    @simple_bb.default_value = 'ReTaskIsMuchTooLongForMaxValue'
    @simple_bb.max_length = 25
    assert_false @simpel_bb.save
    @simple_bb.max_length = 35
    assert_true @simpel_bb.save
  end  
  
  def test_if_min_max_values_are_possible
    @simple_bb.max_length = 3
    @simple_bb.min_length = @simpel_bb.max_length + 2
    assert_false @simpel_bb.save
    @simple_bb.min_length = -5
    assert_false @simpel_bb.save
    @simple_bb.max_length = 25
    assert_true @simpel_bb.save
  end



end