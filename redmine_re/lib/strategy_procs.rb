module StrategyProcs
  
  
  SAVE_OPTIONS_STRATEGY = lambda do | option_string, re_bb | 
    #RAILS_DEFAULT_LOGGER.debug('#################  Called SAVE_OPTIONS_STRATEGY')
    options = option_string.split(%r{,\s*})
    options = options.insert(0, re_bb.default_value) unless options.include? re_bb.default_value
    options = options.delete_if {|x| x == "" }
    existing_options = ReBbOptionSelection.find_all_by_re_bb_selection_id(re_bb.id).map {|x| x.value.to_s}
    options -= existing_options
    options.each do |option|
      ReBbOptionSelection.new(:value => option, :re_bb_selection_id => re_bb.id).save
    end
  end
      
  DO_NOTHING_STRATEGY = lambda do
    true
  end
  
  # This strategy handles the saving of empty arrays. If an array is saved in the
  # database via serialize, an (internal) error occures if no data is filled in the 
  # form which means that rails tries to set the database field to NULL. Instead of 
  # this an empty array shall be stored. 
  # The hash data_field_names is needed if the data field to check is another one 
  # than "referred_artifact_types". The method expects a nil for attribute_names 
  # (using a default) or an hash with the key :fields_to_check and the corresponding  
  # value an array with the name(s) of the data fields to check. 
  SET_EMPTY_ARRAY_IF_NEEDED = lambda do | params_re_bb, re_bb, attribute_names |
    # As procs doesn't work with optional parameters, the user can submit a nil instead.
    # Then the default value is set manually here.
    if attribute_names.nil?
      attribute_names = {:fields_to_check => [:referred_artifact_types]}
    end
    empty_array = []
    # Test for all data fields if null values shall be stored. Transform these values
    # into empty arrays [].
    attribute_names[:fields_to_check].each do |data_field|
      if !params_re_bb.keys.include? data_field.to_s
        params_re_bb[data_field] = empty_array
      end
    end
    re_bb.attributes = params_re_bb
    re_bb
  end
  
  # This method takes an building block and its parameters as well as a hash with three keys to 
  # determine which field(s) should be deleted if some field, specified by the value of the key 
  # "name_of_field_to_check", has not the value specified by the value of the key "value_to_have"
  DELETE_DATA_FROM_DATA_FIELDS_BEFORE_SAVE = lambda do | params_re_bb, re_bb, attribute_names |
    # As procs doesn't work with optional parameters, the user can submit a nil instead.
    # Then the default value is set manually here.
    if attribute_names.nil?
      attribute_names = {:fields_to_delete => [:selected_attributes], :name_of_field_to_check => :embedding_type, :value_to_have => 'attributes' }
    end
    # If the field to check has the same value as given by the key :value_not_to_have, 
    # the data of the fields spezified by the value of the key :fields_to_delete is deleted
    unless eval "re_bb.#{attribute_names[:name_of_field_to_check]} == '#{attribute_names[:value_to_have]}'"
      attribute_names[:fields_to_delete].each do |data_field|
        params_re_bb[data_field] = nil
      end
    end
    re_bb.attributes = params_re_bb
    re_bb
  end
  

  def self.add_error(bb_id, datum_id, bb_error_hash, error_text)
    bb_error_hash[bb_id] = {datum_id => []} if bb_error_hash[bb_id].nil?
    bb_error_hash[bb_id][datum_id] = [] if bb_error_hash[bb_id][datum_id].nil? 
    bb_error_hash[bb_id][datum_id] << error_text
    bb_error_hash
  end
  
  
  # This proc adds an error to the error_hash if the value of the data is not within minimal 
  # and maximal length.
  # This proc needs the Building Block (bb) which user-defined fields shall be checked. The bb 
  # delivered is supposed to allow multiple data. The data is transmitted all together in one 
  # array. As usual, the error_hash as built up since now has to be given to the proc as well.
  #
  # The hash attribute_names is not used here yet.
  VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY = lambda do |bb, datum, bb_error_hash, attribute_names|
    unless bb.min_length.nil?
      if datum.value.length < bb.min_length 
         bb_error_hash = StrategyProcs.add_error(bb.id, datum.id, bb_error_hash, I18n.t(:re_bb_too_short, :bb_name => bb.name, :min_length => bb.min_length))       
      end
    end
    unless bb.max_length.nil?
      if datum.value.length > bb.max_length 
        bb_error_hash = StrategyProcs.add_error(bb.id, datum.id, bb_error_hash, I18n.t(:re_bb_too_long, :bb_name => bb.name, :max_length => bb.max_length))       
      end
    end
    bb_error_hash
  end
 
  # This proc adds an error to the error_hash if for mandatory building blocks no data is saved.
  # This proc needs the Building Block (bb) which user-defined fields shall be checked. The bb 
  # deliverd might allow multiple data. The data is transmitted all together in one 
  # array. As usual, the error_hash as built up since now has to be given to the proc as well.
  # The hash attribute_names is needed if the data to check stores its information in another
  # attribute than "value".
  VALIDATE_MANDATORY_VALUES = lambda do |bb, data_array, bb_error_hash, attribute_names |
    if attribute_names.nil?
      attribute_names = {:value => :value}
    end
    # Multiple data is possible. Don't check for each datum on its own.
    # but check if there is data at all.
    if bb.mandatory?
        if bb_error_hash[bb.id].nil? or bb_error_hash[bb.id][:general].nil? or not bb_error_hash[bb.id][:general].include?(I18n.t(:re_bb_mandatory, :bb_name => bb.name))   
        # There is no general error message stating that the bb is mandatory yet. 
        # So check if there is any data and if not, add the message.
        if data_array.empty? or eval "data_array[0].#{attribute_names[:value]} == ''"
          bb_error_hash = StrategyProcs.add_error(bb.id, :general, bb_error_hash, I18n.t(:re_bb_mandatory, :bb_name => bb.name))         
        end
      end
    end
    bb_error_hash
  end
  
  # This proc adds an error to the error_hash if the building block is out of date. This is
  # possible for example if the Building Block (bb) refers to an artifact and the artifact 
  # was updated after the bb-data was saved. 
  # This proc needs the bb which shall be checked. As usual, the error_hash as built up since 
  # now has to be given to the proc as well. The hash attribute_names is needed if the datum of 
  # the update of the bb is stored in another attribute than "re_checked_at" and the id of the 
  # artifact to check against is not stored in "re_artifact_properties_id"  
  VALIDATE_UP_TO_DATE = lambda do |bb, datum, bb_error_hash, attribute_names |
    if attribute_names.nil?
      attribute_names = {:re_checked_at => :re_checked_at, :re_artifact_relationship_id => :re_artifact_relationship_id, :sink => :sink, :indicate_changes => :indicate_changes}
    end
    # Check if bb is up to date only if changes of the referred artifact shall be indicated
    if eval "bb.#{attribute_names[:indicate_changes].to_s}"
      bb_checked_at = datum[attribute_names[:re_checked_at]]
      relation = ReArtifactRelationship.find(datum[attribute_names[:re_artifact_relationship_id]])
      artifact_id = eval "relation.#{attribute_names[:sink]}.id"
      artifact_updated_at = ReArtifactProperties.find(artifact_id).updated_at
      if artifact_updated_at > bb_checked_at 
        bb_error_hash = StrategyProcs.add_error(bb.id.to_i, datum.id.to_i, bb_error_hash, I18n.t(:re_bb_out_of_date, :bb_name => bb.name))  
      end
    end
    bb_error_hash
  end
  
  
  
end