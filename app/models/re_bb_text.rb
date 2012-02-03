class ReBbText < ReBuildingBlock
  unloadable
  
  has_many :re_bb_data_texts, :dependent => :destroy  
  
  validate :min_max_values_must_be_possible
  
  @@data_form_partial_strategy = 're_building_block/re_bb_text/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_text/multiple_data_form'
  @@additional_work_before_save_strategies = {}
  @@additional_work_after_save_strategies = {}
  @@validation_strategies = {VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY => {:attribute_names => {:min_length => :min_length, :max_length => :max_length, :get_size => :size}}}
  @@validation_whole_data_strategies = {VALIDATE_MANDATORY_VALUES => nil, VALIDATE_MULTIPLE_DATA_NOT_ALLOWED => nil}  
  
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
      # Data should only be saved if no other data object with
      # the same content is existent.
      attributes = datum_hash[id]
      if ReBbDataText.find(:first, :conditions => {:value => attributes[:value], :re_artifact_properties_id => artifact_properties_id, :re_bb_text_id => self.id}).nil?
        # With multiple values possible, the saving of empty data should be forbidden
        unless (attributes[:value].nil? or attributes[:value] == "") and self.multiple_values == true
          #Try to find a bb_data_object with the given id. 
          #If no matching object is found, create a new one
          bb_data = ReBbDataText.find_by_id(id) || ReBbDataText.new
          bb_data.attributes = attributes
          bb_data.re_artifact_properties_id = artifact_properties_id
          bb_data.re_bb_text_id = self.id
          bb_data.save
        end      
      end
    end
  end 
    
  def min_max_values_must_be_possible
    valid = true 
    unless min_length.nil?
      if min_length < 0
        errors.add(:min_length, l(:re_bb_must_not_be_negativ))
        valid = false
      end
    end
    unless max_length.nil?
      if max_length < 0
        errors.add(:max_length, l(:re_bb_must_not_be_negativ))
        valid = false
      end  
    end
    unless min_length.nil? or max_length.nil?
      if min_length > max_length 
        errors.add_to_base(l(:re_bb_max_length_smaller_min_length))
        valid = false
      end   
    end 
    return valid      
  end
  
 
end
