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
  @@validation_strategies = {}
  @@validation_whole_data_strategies = {VALIDATE_MANDATORY_VALUES => {:value => 're_artifact_properties_id'}}
  
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
    id = datum_hash.keys.first
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
      # If no relationship of the given id is existent, create one
      relation = ReArtifactRelationship.find(:first, :conditions => {:id => datum_hash[:re_artifact_realtionship_id]})
      relation_type = datum_hash[id][:relation_type]
      if relation.nil?
        # Try to find a realtionship with the given parameters . If none exsist, create one
        relation = ReArtifactRelationship.find(:first, :conditions => {:source_id => artifact_properties_id, :sink_id => datum_hash[id][:related_artifact_id], :relation_type => relation_type}) || ReArtifactRelationship.new(:source_id => artifact_properties_id, :sink_id => datum_hash[id][:related_artifact_id], :relation_type => relation_type)
        relation.save if relation.new_record?
      else
        # Update existent relationship according to given parameters
        # but only if this relation isn't used by another building block
        if ReBbDataArtifactSelection.find_all_by_re_artifact_relationship_id(relation.id).count == 1
          relation.sink_id = datum_hash[id][:related_artifact_id]
          relation.relation_type = relation_type
          relation.save
        else 
          # Create new relation since the existing one is used by another building block
          relation = ReArtifactRelationship.new(:source_id => artifact_properties_id, :sink_id => datum_hash[id][:related_artifact_id], :relation_type => relation_type)
          relation.save
        end
      end
      # Deleting attributes from datum_hash that were used to
      # create / update the relationship but are not needed for
      # the saving of the artifact_selection_datum
      [:relation_type, :artifact_type, :related_artifact_id].each {|key| datum_hash[id].delete(key)}
      # Try to find a bb_data_object with the given id . 
      # If no matching object is found, create a new one
      bb_data = ReBbDataArtifactSelection.find_by_id(id) || ReBbDataArtifactSelection.new
      datum_hash[id][:re_artifact_relationship_id] = relation.id
      # If data is new, set timestamp of last check on now
      # otherwise the old value of re_checked_at is delivered in
      # the parameter if the user has not checked the relation
      # manually . If he checked it manually, a new timevalue is
      # delivered .
      if bb_data.new_record? 
        datum_hash[id][:re_checked_at] = Time.now       
      end
      bb_data.attributes = datum_hash[id]
      bb_data.re_artifact_properties_id = artifact_properties_id
      bb_data.re_bb_artifact_selection_id = self.id
      bb_data.save  
    end
    
  end
  
end
