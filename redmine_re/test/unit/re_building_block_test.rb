require File.expand_path('../../test_helper', __FILE__)

class ReBuildingBlockTest < ActiveSupport::TestCase
  fixtures :re_building_blocks

  def setup
    @simpel_bb = ReBuildingBlock.new(:name => 'Note', :artifact_type => 'ReGoal')
    @simpel_bb.save
    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
  end
  
  def test_if_artifact_type_is_not_overrideable
    type = @simpel_bb.artifact_type
    @simpel_bb.artifact_type = 'ReTask'
    @simpel_bb.save
    assert_equal @simpel_bb.artifact_type, type
  end  


end

