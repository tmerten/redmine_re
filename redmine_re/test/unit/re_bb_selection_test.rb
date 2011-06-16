require File.expand_path('../../test_helper', __FILE__)

class ReBbSelectionTest < ActiveSupport::TestCase

  fixtures :re_building_blocks, :re_tasks

  def setup
    @simple_bb = ReBbSelection.new(:name => 'Daytime', :artifact_type => 'ReTask')
    @simple_bb.save
    @task_prop = ReTask.find_by_id(Fixtures.identify(:task_test_vocabulary)).re_artifact_properties
    @option_1 = ReBbOptionSelection.new(:value => 'Day', :re_bb_selection_id => @simple_bb.id)
    @option_2 = ReBbOptionSelection.new(:value => 'Night', :re_bb_selection_id => @simple_bb.id)
    @option_1.save
    @option_2.save
    @data = ReBbDataSelection.new(:re_bb_selection_id => @simple_bb.id, :re_artifact_properties_id => @task_prop.id, :re_bb_option_selection_id => @option_1.id)
    @data.save
  end 
  
  def test_if_blank_value_is_not_saved
    # Test if no data is saved if blank value is choosen in selection box
    data = @simple_bb.find_my_data(@task_prop)
    new_datum_hash = {@simple_bb.id => {'no_id' => {:re_bb_selection_id => @simple_bb.id, :re_artifact_properties_id => @task_prop.id, :re_bb_option_selection_id => ''}}}
    ReBuildingBlock.save_data(@task_prop.id, new_datum_hash)
    data_new = @simple_bb.find_my_data(@task_prop)
    assert data == data_new
    # Test if data is deleted, if blank is choosen for existing data
    new_datum_hash = {@simple_bb.id => {@data.id => {:re_bb_selection_id => @simple_bb.id, :re_artifact_properties_id => @task_prop.id, :re_bb_option_selection_id => ''}}}
    ReBuildingBlock.save_data(@task_prop.id, new_datum_hash)
    data_new = @simple_bb.find_my_data(@task_prop)
    assert data_new.empty?
  end



end