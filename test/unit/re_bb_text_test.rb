require File.expand_path('../../test_helper', __FILE__)

class ReBbTextTest < ActiveSupport::TestCase
  
  fixtures :re_building_blocks

  def setup
    @project = Project.find(:first)
    @simple_bb = ReBbText.new
    params = {:re_building_block => {:name => 'Note', :artifact_type => 'ReGoal'}}
    @simple_bb = save_building_block_completely(@simple_bb, params) 
    
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
  
  def test_if_too_long_validation_error_is_added_correctly
    error_hash = {}
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    # Assert that error is added if data value is longer than maximal length
    new_bb = ReBbText.new
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :max_length => 10}}
    new_bb = save_building_block_completely(new_bb, params)
    new_data = ReBbDataText.new(:value => 'New data value with too much text', :re_artifact_properties_id => goal.re_artifact_properties.id, :re_bb_text_id => new_bb.id)
    new_data.save
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash, @project.id)
    assert error_hash[new_bb.id][new_data.id].include?(I18n.t(:re_bb_too_long, :bb_name => new_bb.name, :max_length => new_bb.max_length))
    # Assert that no error is added if data value is longer than maximal length
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :max_length => 100}}
    new_bb = save_building_block_completely(new_bb, params) 
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_too_long, :bb_name => new_bb.name, :max_length => new_bb.max_length))
    # Assert that no error is added if no maximal length is set
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :max_length => ''}}
    new_bb = save_building_block_completely(new_bb, params)  
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_too_long, :bb_name => new_bb.name, :max_length => new_bb.max_length))
  end
  
  def test_if_too_short_validation_error_is_added_correctly
    error_hash = {}
    goal = ReGoal.find_by_id(Fixtures.identify(:goal_small_latency))
    # Assert that error is added if data value is longer than maximal length
    new_bb = ReBbText.new
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :min_length => 10}}
    new_bb = save_building_block_completely(new_bb, params)
    new_data = ReBbDataText.new(:value => 'Short', :re_artifact_properties_id => goal.re_artifact_properties.id, :re_bb_text_id => new_bb.id)
    new_data.save
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash, @project.id)
    assert error_hash[new_bb.id][new_data.id].include?(I18n.t(:re_bb_too_short, :bb_name => new_bb.name, :min_length => new_bb.min_length))
    # Assert that no error is added if data value is shorter than maximal length
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :min_length => 5}}
    new_bb = save_building_block_completely(new_bb, params) 
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_too_short, :bb_name => new_bb.name, :min_length => new_bb.min_length))
    # Assert that no error is added if no minimal length is set
    params = {:re_building_block => {:name => 'New', :artifact_type => 'ReGoal', :min_length => ''}}
    new_bb = save_building_block_completely(new_bb, params)
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(goal.re_artifact_properties, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_too_short, :bb_name => new_bb.name, :min_length => new_bb.min_length))
  end



end
