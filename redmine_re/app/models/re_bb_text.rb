class ReBbText < ReBuildingBlock
  unloadable
  
  include StrategyProcs  

  has_many :re_bb_data_texts   # This does not work properly in test environment.TODO: Ask why
  
  validate :min_max_values_must_be_possible
  
  @@data_form_partial_strategy = 're_building_block/re_bb_text/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_text/multiple_data_form'
  @@additional_work_after_save_strategy = DO_NOTHING_STRATEGY
  @@validation_strategies = [VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY]
  
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
    

  def save_datum(datum_hash, artifact_properties_id)
    id = datum_hash.keys.first
    # Data should only be saved if no other data object with
    # the same content is existent.
    attributes = datum_hash[id]
    if ReBbDataText.find(:first, :conditions => {:value => attributes[:value], :re_artifact_properties_id => artifact_properties_id, :re_bb_text_id => self.id}).nil?
      #Try to find a bb_data_object with the given id . 
      #If no matching object is found, create a new one
      bb_data = ReBbDataText.find_by_id(id) || ReBbDataText.new
      bb_data.attributes = attributes
      bb_data.re_artifact_properties_id = artifact_properties_id
      bb_data.re_bb_text_id = self.id
      bb_data.save 
    end
  end 
  
  def validate_for_spezification(datum, bb_error_hash)
    @@validation_strategies.each do |validation_strategy|
      bb_error_hash = validation_strategy.call(self, datum, bb_error_hash)    
    end
    bb_error_hash
  end
  
  def min_max_values_must_be_possible
    unless min_length.nil?
      if min_length < 0
        errors.add(:value, l(:re_bb_min_length_under_zero))
        return false
      end
    end
    unless max_length.nil?
      if max_length < 0
        errors.add(:value, l(:re_bb_max_length_under_zero))
        return false
      end  
    end
    unless min_length.nil? or max_length.nil?
      if min_length > max_length 
        errors.add_to_base(l(:re_bb_max_length_smaller_min_length))
        return false
      end   
    end
      
    true      
  end
  
 
end