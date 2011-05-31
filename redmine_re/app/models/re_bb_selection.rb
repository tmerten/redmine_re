class ReBbSelection < ReBuildingBlock
  unloadable
  
  include StrategyProcs

  #has_many :re_bb_data, :class_name => 'ReBbDataText'
  has_many :re_bb_data_selections   # This does not work properly in test environment.TODO: Ask why
  has_many :re_bb_option_selections
  
  
  @@data_form_partial_strategy = 're_building_block/re_bb_selection/data_form'
  @@additional_work_after_save_strategy = SAVE_OPTIONS_STRATEGY
  
  #ToDo: Vielleicht später auslagern in eigenes Modul
  def data_form_partial_strategy
    @@data_form_partial_strategy
  end
  
  def additional_work_after_save_strategy
    @@additional_work_after_save_strategy
  end
  

  def save_datum(datum_hash, artifact_properties_id)
    id = datum_hash.keys.first
    #Try to find a bb_data_object with the given id . 
    #If no matching object is found, create a new one
    bb_data = ReBbDataSelection.find_by_id(id) || ReBbDataSelection.new
    bb_data.attributes = datum_hash[id]
    bb_data.re_artifact_properties_id = artifact_properties_id
    bb_data.re_bb_selection_id = self.id
    bb_data.save  
    
  end 
  
   
  
end