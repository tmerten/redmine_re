class ReBbSelection < ReBuildingBlock
  unloadable

  has_many :re_bb_data_selections, :dependent => :destroy  
  has_many :re_bb_option_selections, :dependent => :destroy 
  
  
  @@data_form_partial_strategy = 're_building_block/re_bb_selection/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_selection/multiple_data_form'
  @@additional_work_before_save_strategies = {}
  @@additional_work_after_save_strategies = {SAVE_OPTIONS_STRATEGY => nil}
  @@validation_strategies = {}
  @@validation_whole_data_strategies = {VALIDATE_MANDATORY_VALUES => {:attribute_names => {:value => 're_bb_option_selection_id'}, :error_messages => nil}, 
                                        VALIDATE_MULTIPLE_DATA_NOT_ALLOWED => nil}
                                                                        
  def data_form_partial_strategy
    @@data_form_partial_strategy
  end
  
  def multiple_data_form_partial_strategy
    @@multiple_data_form_partial_strategy
  end
  
  def additional_work_before_save_strategies
    @@additional_work_before_save_strategies
  end
    
  def additional_work_after_save_strategies
    @@additional_work_after_save_strategies
  end
  
  def validation_strategies
    @@validation_strategies
  end
  
  def validation_whole_data_strategies
    @@validation_whole_data_strategies
  end

  def save_datum(datum_hash, artifact_properties_id)
    datum_hash.keys.each do |id|
      # Save new datum only if this wouldn't result in a duplicate
      if ReBbDataSelection.find(:first, :conditions => {:re_bb_option_selection_id => datum_hash[id][:re_bb_option_selection_id], :re_artifact_properties_id => artifact_properties_id, :re_bb_selection_id => self.id}).nil?
        #Try to find a bb_data_object with the given id . 
        #If no matching object is found, create a new one
        bb_data = ReBbDataSelection.find_by_id(id) || ReBbDataSelection.new
        # Test if user chose to overwrite existing data (only possible in case of single data)
        if !bb_data.new_record? and datum_hash[id][:re_bb_option_selection_id] == ''
          bb_data.delete
        else
          unless datum_hash[id][:re_bb_option_selection_id] == ''
            bb_data.attributes = datum_hash[id]
            bb_data.re_artifact_properties_id = artifact_properties_id
            bb_data.re_bb_selection_id = self.id
            bb_data.save
          end
        end
      end
    end
  end 
  
  
end