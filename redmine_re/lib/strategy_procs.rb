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
  
  

  def self.add_error(bb_id, datum_id, bb_error_hash, error_text)
    bb_error_hash[bb_id] = {datum_id => []} if bb_error_hash[bb_id].nil?
    bb_error_hash[bb_id][datum_id] = [] if bb_error_hash[bb_id][datum_id].nil? 
    bb_error_hash[bb_id][datum_id] << error_text
    bb_error_hash
  end
  
  
  # This proc adds an error to the error_hash if the value of the data is not within minimal 
  # and maximal length.
  # This proc needs the Building Block (bb) which user-defined fields shall be checked. The bb 
  # deliverd is supposed to allow multiple data. The data is transmitted all together in one 
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
  # deliverd is supposed to allow multiple data. The data is transmitted all together in one 
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
  
  
  
end