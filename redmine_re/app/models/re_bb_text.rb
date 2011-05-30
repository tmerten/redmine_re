class ReBbText < ReBuildingBlock

  #has_many :re_bb_data, :class_name => 'ReBbDataText'
  has_many :re_bb_data_texts   # This does not work properly in test environment.TODO: Ask why
  
  validate :min_max_values_must_be_possible, :default_value_is_not_allowed_outside_min_max 
  
  @@data_form_partial_strategy = 're_building_block/re_bb_text/data_form'
  
  def data_form_partial_strategy
    @@data_form_partial_strategy
  end
  

  def save_datum(datum_hash, artifact_properties_id)
    id = datum_hash.keys.first
    # Only if other data than default value is delivered,
    # a save operation is needed
    attributes = datum_hash[id]
    if attributes[:value] != self.default_value
      #Try to find a bb_data_object with the given id . 
      #If no matching object is found, create a new one
      bb_data = ReBbDataText.find_by_id(id) || ReBbDataText.new
      bb_data.attributes = attributes
      bb_data.re_artifact_properties_id = artifact_properties_id
      bb_data.re_bb_text_id = self.id
      bb_data.save 
    end    
  end 
  
  def min_max_values_must_be_possible
    min_length = 0 if min_length.nil? 
    max_length = 99999 if max_length.nil? 
    if min_length < 0
      errors.add(:value, l(:re_bb_min_length_under_zero))
      return false
    end
    if max_length < 0
      errors.add(:value, l(:re_bb_max_length_under_zero))
      return false
    end
    if min_length > max_length 
      errors.add_to_base(l(:re_bb_max_length_smaller_min_length))
      return false
    end   
    true      
  end
  
  def default_value_is_not_allowed_outside_min_max
    min_length = 0 if min_length.nil? 
    max_length = 99999 if max_length.nil?
    if default_value.length > max_length || default_value.length < min_length
      errors.add(:default_value, l(:re_bb_default_value_outside_min_max))
    end
  end
    
  
end