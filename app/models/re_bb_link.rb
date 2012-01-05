class ReBbLink < ReBuildingBlock
  unloadable

  has_many :re_bb_data_links, :dependent => :destroy  
  
  @@data_form_partial_strategy = 're_building_block/re_bb_link/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_link/multiple_data_form'
  @@additional_work_before_save_strategies = {}
  @@additional_work_after_save_strategies = {}
  @@validation_strategies = {}
  @@validation_whole_data_strategies = {}  
  
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
      
      logger.debug(attributes.to_yaml)
      if ReBbDataLink.find(:first, :conditions => {:url => attributes[:url], :re_artifact_properties_id => artifact_properties_id, :re_bb_link_id => self.id}).nil?
        # With multiple values possible, the saving of empty data should be forbidden
        unless (attributes[:url].nil? or attributes[:url] == "")
          if attributes[:description].blank?
            attributes[:description] = attributes[:url]
          end
          #Try to find a bb_data_object with the given id. 
          #If no matching object is found, create a new one
          bb_data = ReBbDataLink.find_by_id(id) || ReBbDataLink.new
          bb_data.attributes = attributes
          bb_data.re_artifact_properties_id = artifact_properties_id
          bb_data.re_bb_link_id = self.id
          bb_data.save
        end      
      end
    end
  end 
  
end