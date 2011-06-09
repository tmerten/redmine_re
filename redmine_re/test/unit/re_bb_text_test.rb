require File.expand_path('../../test_helper', __FILE__)
require 'vendor/plugins/redmine_re/app/models/re_building_block'

class ReBbTextTest < ActiveSupport::TestCase

  def setup
    @simple_bb = ReBbText.new(:name => 'Note', :artifact_type => 'ReGoal')
    @simple_bb.save
    @complex_bb_text = ReBuildingBlock.find_by_name('Solution Ideas')
  end 
  
  def test_if_min_max_values_are_possible
    @simple_bb.max_length = 3
    @simple_bb.min_length = @simple_bb.max_length + 2
    assert ! @simple_bb.save
    @simple_bb.min_length = -5
    assert ! @simple_bb.save
    @simple_bb.max_length = -5
    assert ! @simple_bb.save 
    @simple_bb.min_length = 25
    @simple_bb.max_length = 35
    assert @simple_bb.save
  end



end