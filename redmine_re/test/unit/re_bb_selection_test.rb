require File.expand_path('../../test_helper', __FILE__)

class ReBbSelectionTest < ActiveSupport::TestCase

  fixtures :re_building_blocks, :re_tasks

  def setup
    @project = Project.find(:first)
    @simple_bb = ReBbSelection.new
    params = {:re_building_block => {:name => 'Daytime', :artifact_type => 'ReTask'}, :options => ''}
    @simple_bb = save_building_block_completely(@simple_bb, params) 
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
  
  
  def test_if_options_are_created_correctly_out_of_parameter_strings
    options_count = ReBbOptionSelection.find(:all, :conditions => {:re_bb_selection_id => @simple_bb.id}).count
    # Create new options out of default and out of options string
    params = {:re_building_block => {:name => 'Daytime', :artifact_type => 'ReTask', :default_value => 'Latenight'}, :options => 'Morning, Afternoon, Noon, Evening'}
    @simple_bb = save_building_block_completely(@simple_bb, params) 
    new_options_count = ReBbOptionSelection.find(:all, :conditions => {:re_bb_selection_id => @simple_bb.id}).count
    assert_equal options_count + 5, new_options_count
    options_count = new_options_count
    # Check if the default value is changed to an already existing option, that one is not created twice
    params = {:re_building_block => {:name => 'Daytime', :artifact_type => 'ReTask', :default_value => 'Morning'}, :options => ''}
    @simple_bb = save_building_block_completely(@simple_bb, params) 
    new_options_count = ReBbOptionSelection.find(:all, :conditions => {:re_bb_selection_id => @simple_bb.id}).count
    assert_equal options_count, new_options_count
    # Check if only options are created, which values do not exist already
    params = {:re_building_block => {:name => 'Daytime', :artifact_type => 'ReTask', :default_value => 'Dawn'}, :options => 'Afternoon, Morning, Dawn, Twilight'}
    @simple_bb = save_building_block_completely(@simple_bb, params) 
    new_options_count = ReBbOptionSelection.find(:all, :conditions => {:re_bb_selection_id => @simple_bb.id}).count
    assert_equal options_count + 2, new_options_count
  end
  
  def test_validation_of_mandatory_values
    # This test is needed because the data of bb_selection has no "value" attribute
    # Test if with no data and with mandatory attribute in config set to false,
    # no error message shall occure
    my_bb = ReBbSelection.new()
    params = {:re_building_block => {:name => 'NotMandatory', :artifact_type => 'ReTask', :default_value => '1', :mandatory => false}, :options => '2, 3, 4'}
    my_bb = save_building_block_completely(my_bb, params) 
    assert_equal my_bb.re_bb_data_selections.count, 0
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_mandatory, :bb_name => my_bb.name)) 
    # Change configuration so that building block data is mandatory
    # Test if error message occurs.
    params = {:re_building_block => {:name => 'Mandatory', :artifact_type => 'ReTask', :default_value => '1', :mandatory => true}, :options => '2, 3, 4'}
    my_bb = save_building_block_completely(my_bb, params) 
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert extract_error_messages(error_hash).include?(I18n.t(:re_bb_mandatory, :bb_name => my_bb.name)) 
    # Create data and test if error_message is gone again
    option = my_bb.re_bb_option_selections.first
    params = {my_bb.id => {'no_id' => {:re_bb_selection_id => my_bb.id, :re_bb_option_selection_id => option.id, :re_artifact_properties_id => @task_prop.id}}}
    ReBuildingBlock.save_data(@task_prop.id, params)
    error_hash = {}
    error_hash = ReBuildingBlock.validate_building_blocks(@task_prop, error_hash, @project.id)
    assert ! extract_error_messages(error_hash).include?(I18n.t(:re_bb_mandatory, :bb_name => my_bb.name)) 
  end

end