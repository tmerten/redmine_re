module StrategyProcs
  
  

###### Additional work before save strategies ###### 



  # This strategy handles the saving of empty arrays. If an array is saved in the
  # database via serialize, an (internal) error occures if no data is filled in the 
  # form which means that rails tries to set the database field to NULL. Instead of 
  # this an empty array shall be stored. 
  #
  # This proc takes all the parameters for the building block and the building block
  # (bb) itself. The hash attribute_names is only needed if the following information  
  # is not available as described below.
  # The value of the key "fields_to_check" is is is an array with the names of the bb's 
  #                       attributes to check. If they are not set yet, an empty array is set.
  # If no attribute_names hash is delivered, a default hash with values matching the artifact 
  # selection bb is created.
  SET_EMPTY_ARRAY_IF_NEEDED = lambda do | re_bb, params, attribute_names |
    if attribute_names.nil?
      attribute_names = {:fields_to_check => [:referred_artifact_types]}
    end
    empty_array = []
    params_re_bb = params[:re_building_block]
    # Test for all data fields if null values shall be stored. Transform these values
    # into empty arrays [].
    attribute_names[:fields_to_check].each do |data_field|
      if !params_re_bb.keys.include? data_field.to_s and !params_re_bb.keys.include? data_field.to_sym
        params_re_bb[data_field] = empty_array
      end
    end
    re_bb.attributes = params_re_bb
    re_bb
  end
    
  
  # This method takes an building block (bb) and its parameters as well as a hash with three keys to 
  # determine which field(s) should be deleted if some field, specified by the value of the key 
  # "name_of_field_to_check", has not the value specified by the value of the key "value_not_to_have".
  #
  # This proc takes all the parameters for the building block and the building block (bb) itself.
  # The hash attribute_names is only needed if the following information is not available in the way 
  # described below:
  # The value of the key "fields_to_delete" is is an array with the names of the bb's attributes to delete
  # The value of the key "name_of_field_to_check" is the name of the bb's attribute which should not have the 
  #            same value as specified by the value of the key value_not_to_have 
  # The value of the key "value_not_to_have" defines the value which the field defined by the value of  
  #                       the key "name_of_field_to_check" should not have 
  # If no attribute_names hash is delivered, a default hash with values matching the artifact 
  # selection building block is created.
  DELETE_DATA_FROM_DATA_FIELDS_BEFORE_SAVE = lambda do | re_bb, params, attribute_names |
    if attribute_names.nil?
      attribute_names = {:fields_to_delete => [:selected_attributes], :name_of_field_to_check => :embedding_type, :value_not_to_have => 'attributes' }
    end
    params_re_bb = params[:re_building_block]
    # If the field to check has the same value as given by the key :value_not_to_have, 
    # the data of the fields spezified by the value of the key :fields_to_delete is deleted
    unless eval "re_bb.#{attribute_names[:name_of_field_to_check]} == '#{attribute_names[:value_not_to_have]}'"
      attribute_names[:fields_to_delete].each do |data_field|
        params_re_bb[data_field] = nil
      end
    end
    re_bb.attributes = params_re_bb
    re_bb
  end
  
  
  
###### Additional work after save strategies ###### 



  # This strategy generates objects of the ReOptionSelection-class from a string of words
  # delivered in the params hash. Each word becomes on option if no option with this value
  # is existant yet. 
  #
  # This proc takes all the parameters for the building block and the building block
  # (bb) itself. The hash attribute_names is only needed if the following information  
  # is not available as described below.
  # The value of the key "param_path_to_option_string" is a string which symbolises the path in   
  #                       the params hash to get the string of words needed for the generation
  # If no attribute_names hash is delivered, a default hash with values matching the selection 
  # bb is created.
  SAVE_OPTIONS_STRATEGY = lambda do | re_bb, params, attribute_names | 
  if attribute_names.nil?
      attribute_names = {:param_path_to_option_string => '[:options]'}
    end
    option_string = eval "params#{attribute_names[:param_path_to_option_string]}"
    options = option_string.split(%r{,\s*})
    options = options.insert(0, re_bb.default_value) unless options.include? re_bb.default_value
    options = options.delete_if {|x| x == "" or x.nil?}
    existing_options = ReBbOptionSelection.find_all_by_re_bb_selection_id(re_bb.id).map {|x| x.value.to_s}
    options -= existing_options
    options.each do |option|
      option_object = ReBbOptionSelection.new(:value => option, :re_bb_selection_id => re_bb.id).save
    end
    re_bb
  end



###### Validation strategies ###### 



  # This proc adds an error to the error_hash if the value of the data is not within minimal 
  # and maximal length.
  #
  # This proc needs the Building Block (bb) which user-defined fields shall be checked. The bb 
  # delivered is supposed to allow multiple data. The data is transmitted all together in one 
  # array. As usual, the error_hash (as built up since now) has to be given to the proc as well.
  # The hash attribute_names is only needed if the following information is not available as described below.
  # The value of the key "min_length" is the name of the bb's attribute which stores the minimal 
  #            length of the data value
  # The value of the key "max_length" is the name of the bb's attribute which stores the maximal 
  #                  length of the data value
  # If no attribute_names hash is delivered, a default hash with values being the same as the keys is created.
  VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY = lambda do |re_bb, datum, bb_error_hash, attribute_names|
    if attribute_names.nil?
      attribute_names = {:min_length => :min_length, :max_length => :max_length}
    end
    unless datum.value == ""
      min = eval "re_bb.#{attribute_names[:min_length]}"
      max = eval "re_bb.#{attribute_names[:max_length]}"
      unless min.nil?
        if datum.value.length < min 
           bb_error_hash = StrategyProcs.add_error(re_bb.id, datum.id, bb_error_hash, I18n.t(:re_bb_too_short, :bb_name => re_bb.name, :min_length => min))       
        end
      end
      unless max.nil?
        if datum.value.length > max 
          bb_error_hash = StrategyProcs.add_error(re_bb.id, datum.id, bb_error_hash, I18n.t(:re_bb_too_long, :bb_name => re_bb.name, :max_length => max))       
        end
      end
    end
    bb_error_hash
  end
  
  
  
  # This proc adds an error to the error_hash if the building block data is out of date. This is
  # possible for example if the Building Block (bb) refers to an artifact by some relationship and 
  # the artifact was updated after the bb-data was saved. 
  #
  # This proc needs the bb and the datum which shall be checked. As usual, the error_hash as built up since 
  # now has to be given to the proc as well. The hash attribute_names is only needed if the following 
  # information is not available as described below.
  # The value of the key "re_checked_at" is the name of the datum attribute which stores the datum of the last check of the data
  # The value of the key "re_relationship_id" is the name of the datum attribute which stores the id of a relationship which
  #                      leads to an artifact whose updated_at attribute shall be checked against re_checked_at
  # The value of the key "sink" is the method of the relationship object with the id re_relationship_id which delivers the artifact 
  #                whose updated_at attribute shall be checked against re_checked_at
  # The value of the key "indicate_changes" is the name of the building_block attribute which states if 
  # If no attribute_names hash is delivered, a default hash with values being the same as the keys is created.
  VALIDATE_UP_TO_DATE = lambda do |re_bb, datum, bb_error_hash, attribute_names |
    if attribute_names.nil?
      attribute_names = {:re_checked_at => :re_checked_at, :re_artifact_relationship_id => :re_artifact_relationship_id, :sink => :sink, :indicate_changes => :indicate_changes}
    end
    # Check if bb is up to date only if changes of the referred artifact shall be indicated
    if eval "re_bb.#{attribute_names[:indicate_changes].to_s}"
      bb_checked_at = datum[attribute_names[:re_checked_at]]
      relation = ReArtifactRelationship.find(datum[attribute_names[:re_artifact_relationship_id]])
      artifact_id = eval "relation.#{attribute_names[:sink]}.id"
      artifact_updated_at = ReArtifactProperties.find(artifact_id).updated_at
      if artifact_updated_at > bb_checked_at 
        bb_error_hash = StrategyProcs.add_error(re_bb.id.to_i, datum.id.to_i, bb_error_hash, I18n.t(:re_bb_out_of_date, :bb_name => re_bb.name))  
      end
    end
    bb_error_hash
  end  
  
  
  # This proc adds an error to the error_hash if the building block's data doesn't match its
  # configuration. This can be the case when the bb's configuration was changed after the 
  # creation of the data. Up to now this strategy is only used for the ReBbArtifactSelection,
  # to add an error if the selected artifact types do not match the type of the referred artifact
  # any longer.
  #
  # This proc needs the bb which shall be checked. As usual, the error_hash (as built up since 
  # now) has to be given to the proc as well. The hash attribute_names is only needed in the proc's 
  # parameter list to match the interface of all validation strategies, as this strategy is too 
  # particular to be reused.
  VALIDATE_DATUM_FITS_CONFIG = lambda do |re_bb, datum, bb_error_hash, attribute_names |
    relation = ReArtifactRelationship.find(datum.re_artifact_relationship_id)
    sink = ReArtifactProperties.find(relation.sink_id)
    unless re_bb.referred_relationship_types.nil? or re_bb.referred_relationship_types.empty? or re_bb.referred_relationship_types.include?(relation.relation_type)
      bb_error_hash = StrategyProcs.add_error(re_bb.id.to_i, datum.id.to_i, bb_error_hash, I18n.t(:re_bb_relation_type_does_not_match, :type => I18n.t('re_' + relation.relation_type.to_s)))  
    end
    unless re_bb.referred_artifact_types.nil? or re_bb.referred_artifact_types.empty? or re_bb.referred_artifact_types.include?(sink.artifact_type)
      bb_error_hash = StrategyProcs.add_error(re_bb.id.to_i, datum.id.to_i, bb_error_hash, I18n.t(:re_bb_artifact_type_does_not_match, :type => I18n.t(sink.artifact_type)))  
    end
    bb_error_hash
  end 
  
  
  
###### Validation whole data strategies #######
  

  
  # This proc adds an error to the error_hash if for mandatory building blocks no data is saved.
  #
  # This proc needs the Building Block (bb) which fields shall be checked. The bb 
  # deliverd might allow multiple data. The data is transmitted all together in one 
  # array. As usual, the error_hash (as built up since now) has to be given to the proc as well.
  # The hash attribute_names is only needed if the following information is not available as described below.
  # The value of the key "value" is the name of the datum attribute which stores the actual data information
  #             (e.g. the value or the id of an option or relationship) 
  # If no attribute_names hash is delivered, a default hash with values being the same as the keys is created.
  VALIDATE_MANDATORY_VALUES = lambda do |re_bb, data_array, bb_error_hash, attribute_names |
    if attribute_names.nil?
      attribute_names = {:value => :value}
    end
    # Multiple data is possible. Don't check for each datum on its own.
    # but check if there is data at all.
    if re_bb.mandatory?
        if bb_error_hash[re_bb.id].nil? or bb_error_hash[re_bb.id][:general].nil? or not bb_error_hash[re_bb.id][:general].include?(I18n.t(:re_bb_mandatory, :bb_name => re_bb.name))   
        # There is no general error message stating that the bb is mandatory yet. 
        # So check if there is any data and if not, add the message.
        if data_array.empty? or eval "data_array[0].#{attribute_names[:value]} == ''"
          bb_error_hash = StrategyProcs.add_error(re_bb.id, :general, bb_error_hash, I18n.t(:re_bb_mandatory, :bb_name => re_bb.name))         
        end
      end
    end
    bb_error_hash
  end
  
  
  # This proc adds an error to the error_hash if the building block (bb) has more data entries 
  # than allowed. This can be the case when the bb was configured to allow multiple values
  # before but the configuration was changed to allow single data values only. 
  #
  # This proc needs the bb which shall be checked. As usual, the error_hash (as built up since 
  # now) has to be given to the proc as well. The hash attribute_names is only needed in the proc's 
  # parameter list to match the interface of all validation strategies, as this proc only operated 
  # on attributes belonging to the building block base class "ReBuildingBlock".
  VALIDATE_MULTIPLE_DATA_NOT_ALLOWED = lambda do |re_bb, data_array, bb_error_hash, attribute_names |
    # Check bb only if no multiple data is allowed
    unless re_bb.multiple_values
      if bb_error_hash[re_bb.id].nil? or bb_error_hash[re_bb.id][:general].nil? or not bb_error_hash[re_bb.id][:general].include?(I18n.t(:re_bb_no_multiple_data_allowed, :bb_name => re_bb.name))   
        # There is no general error message stating that no multiple data is allowed yet. 
        # So check if there are to many data elements
        if data_array.count > 1
          bb_error_hash = StrategyProcs.add_error(re_bb.id, :general, bb_error_hash, I18n.t(:re_bb_no_multiple_data_allowed, :bb_name => re_bb.name))         
        end
      end
    end
    bb_error_hash
  end  
  
  
  
###### Helper methods ######  
  
    
  # This method adds an error tho the error hash and returns the hash.
  def self.add_error(bb_id, datum_id, bb_error_hash, error_text)
    bb_error_hash[bb_id] = {datum_id => []} if bb_error_hash[bb_id].nil?
    bb_error_hash[bb_id][datum_id] = [] if bb_error_hash[bb_id][datum_id].nil? 
    bb_error_hash[bb_id][datum_id] << error_text
    bb_error_hash
  end
  
    
  
end