class ReBbText < ReBuildingBlock

  #has_many :re_bb_data, :class_name => 'ReBbDataText'
  has_many :re_bb_data_texts   # This does not work properly in test environment.TODO: Ask why
  
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
  
end