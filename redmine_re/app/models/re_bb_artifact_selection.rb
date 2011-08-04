class ReBbArtifactSelection < ReBuildingBlock
  unloadable
  
  include StrategyProcs

  has_many :re_bb_data_artifact_selections 
  
  # To store an array of attributes in a text column without further work
  serialize :selected_attributes
  serialize :referred_artifact_types
  serialize :referred_relationship_types
  
  
  @@data_form_partial_strategy = 're_building_block/re_bb_artifact_selection/data_form'
  @@multiple_data_form_partial_strategy = 're_building_block/re_bb_artifact_selection/multiple_data_form'
  @@additional_work_before_save_strategies = {SET_EMPTY_ARRAY_IF_NEEDED => {:fields_to_check => [:referred_artifact_types, :referred_relationship_types]},
                                              DELETE_DATA_FROM_DATA_FIELDS_BEFORE_SAVE => nil}
  @@additional_work_after_save_strategy = DO_NOTHING_STRATEGY
  @@validation_strategies = {VALIDATE_UP_TO_DATE => nil, 
                             VALIDATE_DATUM_FITS_CONFIG => nil}
  @@validation_whole_data_strategies = {VALIDATE_MANDATORY_VALUES => {:value => 're_artifact_properties_id'}, 
                                        VALIDATE_MULTIPLE_DATA_NOT_ALLOWED => nil}
  
  #ToDo: später auslagern in eigenes Modul
  def data_form_partial_strategy
    @@data_form_partial_strategy
  end
  
  def multiple_data_form_partial_strategy
    @@multiple_data_form_partial_strategy
  end
  
  def additional_work_before_save_strategies
    @@additional_work_before_save_strategies
  end
  
  def additional_work_after_save_strategy
    @@additional_work_after_save_strategy
  end
  
  def validation_strategies
    @@validation_strategies
  end
  
  def validation_whole_data_strategies
    @@validation_whole_data_strategies
  end



  def save_datum(datum_hash, artifact_properties_id)
    datum_hash.keys.each do |id|
      # If only the parameter 'confirm_checked' is given, try to update
      # the corresponding data by setting the re_checked_at attribute to now.
      if id != 'no_id' and datum_hash[id][:confirm_checked] == '1'
        begin
          bb_data = ReBbDataArtifactSelection.find_by_id(id)
          bb_data.re_checked_at = Time.now
          bb_data.save
        end
      else
        # normal treatment of parameters
        
        # If no artifact is choosen, data that is already existant 
        # will be deleted, if the bb is not configured to accept multiple  
        # data. The relationship won't be deleted since we do not know
        # if it was created especially for the building block or not .
        if datum_hash[id][:related_artifact_id] == ""
          # if no multiple values are allowed, delete given data
          # else do nothing
          if ! self.multiple_values
            bb_data = ReBbDataArtifactSelection.find_by_id(id)
            bb_data.delete unless bb_data.nil?
          end    
        else
          # An artifact is choosen. Therefore check relationships.
          # Try to find a realtionship with the given parameters . If none exsist, create one
          relation = ReArtifactRelationship.find(:first, :conditions => {:source_id => artifact_properties_id, :sink_id => datum_hash[id][:related_artifact_id], :relation_type => datum_hash[id][:relation_type]}) || ReArtifactRelationship.new(:source_id => artifact_properties_id, :sink_id => datum_hash[id][:related_artifact_id], :relation_type => datum_hash[id][:relation_type])
          relation.save if relation.new_record?
          # Try to find a bb_data_object with the given id . 
          # If no matching object is found, create a new one
          bb_data = ReBbDataArtifactSelection.find_by_id(id) || ReBbDataArtifactSelection.new    
          # Checking if new data is submitted by the user. This results in 
          # another relation used for the bb. If another relation is used, 
          # it was checked and confirmed by the user. Therefore the timestamp 
          # of the last check has to be updated.
          other_relation = true unless relation.id == bb_data.re_artifact_relationship_id
          # If data is new or another relation is used, set timestamp 
          # of last check to now. This is done as well if the user checked 
          # the relation manually by checking a corresponding checkbox.
          if bb_data.new_record? or other_relation or datum_hash[id][:confirm_checked]  
            datum_hash[id][:re_checked_at] = Time.now     
          end
          ## Preparing save of data
          # Deleting attributes from datum_hash that were used to
          # create / update the relationship but are not needed for
          # the saving of the artifact_selection_datum
          [:relation_type, :artifact_type, :related_artifact_id, :confirm_checked].each {|key| datum_hash[id].delete(key)}
          datum_hash[id][:re_artifact_relationship_id] = relation.id
          bb_data.attributes = datum_hash[id]
          bb_data.re_artifact_properties_id = artifact_properties_id
          bb_data.re_bb_artifact_selection_id = self.id
          bb_data.save  
        end
      end      
    end
  end
  
  
end
