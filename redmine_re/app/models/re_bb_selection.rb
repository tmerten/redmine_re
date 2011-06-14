class ReBbSelection < ReBuildingBlock
  unloadable
  
  include StrategyProcs

  has_many :re_bb_data_selections 
  has_many :re_bb_option_selections
  
  
  @@data_form_partial_strategy = 're_building_block/re_bb_selection/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_selection/multiple_data_form'
  @@additional_work_after_save_strategy = SAVE_OPTIONS_STRATEGY
  @@validation_strategies = []
  
  #ToDo: Vielleicht später auslagern in eigenes Modul
  def data_form_partial_strategy
    @@data_form_partial_strategy
  end
  
  def multiple_data_form_partial_strategy
    @@multiple_data_form_partial_strategy
  end
  
  def additional_work_after_save_strategy
    @@additional_work_after_save_strategy
  end
  
  def validation_strategies
    @@validation_strategies
  end
  

  def save_datum(datum_hash, artifact_properties_id)
    id = datum_hash.keys.first
    if ReBbDataSelection.find(:first, :conditions => {:re_bb_option_selection_id => datum_hash[id][:re_bb_option_selection_id], :re_artifact_properties_id => artifact_properties_id, :re_bb_selection_id => self.id}).nil?
      #Try to find a bb_data_object with the given id . 
      #If no matching object is found, create a new one
      bb_data = ReBbDataSelection.find_by_id(id) || ReBbDataSelection.new
      bb_data.attributes = datum_hash[id]
      bb_data.re_artifact_properties_id = artifact_properties_id
      bb_data.re_bb_selection_id = self.id
      bb_data.save 
    end
  end 
  
  def validate_for_specification(datum, bb_error_hash)
    @@validation_strategies.each do |validation_strategy|
      bb_error_hash = validation_strategy.call(self, datum, bb_error_hash)    
    end
    bb_error_hash
  end
  
   
  
end