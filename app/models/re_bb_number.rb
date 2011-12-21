class ReBbNumber < ReBuildingBlock
  unloadable
  
  has_many :re_bb_data_numbers, :dependent => :destroy
  
  validate :min_max_values_must_be_possible
  validate :number_of_digits, :numericality => {:only_integer => true}
  validates_numericality_of :minimal_value, :maximal_value
  
  
  @@data_form_partial_strategy = 're_building_block/re_bb_number/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_number/multiple_data_form' 
  @@validation_strategies = {}
  @@validation_whole_data_strategies = {} 
  @@additional_work_before_save_strategies = {}
  @@additional_work_after_save_strategies = {}
  @@validation_strategies = {VALIDATE_NUMBER_FORMAT => nil, 
                             VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY => {:attribute_names => {:min_length => :minimal_value, :max_length => :maximal_value, :value => 'datum.value'}, :error_messages => {:re_bb_too_short => :re_bb_too_small, :re_bb_too_long => :re_bb_too_big}}}
  @@validation_whole_data_strategies = {VALIDATE_MANDATORY_VALUES => nil, 
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
      attributes = datum_hash[id]
      # With multiple values possible, the saving of empty data should be forbidden
      unless (attributes[:value].nil? or attributes[:value] == "") and self.multiple_values == true
        #Try to find a bb_data_object with the given id. 
        #If no matching object is found, create a new one
        bb_data = ReBbDataNumber.find_by_id(id) || ReBbDataNumber.new
        bb_data.attributes = attributes
        bb_data.re_artifact_properties_id = artifact_properties_id
        bb_data.re_bb_number_id = self.id
        bb_data.save
      end      
    end
  end 
    
  def min_max_values_must_be_possible
    valid = true 
    unless minimal_value.nil? or maximal_value.nil?
      if minimal_value > maximal_value 
        errors.add_to_base(l(:re_bb_max_value_smaller_minimal_value))
        valid = false
      end   
    end 
    if number_format == 'integer'
      unless minimal_value.nil?
        if minimal_value < 0
          errors.add(:minimal_value, l(:re_bb_must_not_be_negative))
          valid = false
        end
        if minimal_value - minimal_value.truncate != 0
          errors.add(:minimal_value, l(:re_bb_must_be_integer))
          valid = false
        end
      end
      unless maximal_value.nil?
        if maximal_value < 0
          errors.add(:maximal_value, l(:re_bb_must_not_be_negative))
          valid = false
        end
        if maximal_value - maximal_value.truncate != 0
          errors.add(:maximal_value, l(:re_bb_must_be_integer))
          valid = false
        end
      end
    end
    return valid   
     
  end
  
  
end
