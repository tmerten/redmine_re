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
    #RAILS_DEFAULT_LOGGER.debug('#################  Called DO_NOTHING_STRATEGY')
    true
  end
  
  # Maybe a hash for translating context variable names in expected names is needed when re-used.

  VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY = lambda do |bb, datum, bb_error_hash|
    #RAILS_DEFAULT_LOGGER.debug('#################  Called VALIDATE_VALUE_BETWEEN_MIN_VALUE_AND_MAX_VALUE_STRATEGY')
    unless bb.min_length.nil?
      if datum.value.length < bb.min_length 
        bb_error_hash[bb.id] = {datum.id => []} if bb_error_hash[bb.id].nil?
        bb_error_hash[bb.id][datum.id] = [] if bb_error_hash[bb.id][datum.id].nil? 
        bb_error_hash[bb.id][datum.id] << I18n.t(:re_bb_too_short, :bb_name => bb.name, :min_length => bb.min_length)       
      end
    end
    unless bb.max_length.nil?
      if datum.value.length > bb.max_length 
        bb_error_hash[bb.id] = {datum.id => []} if bb_error_hash[bb.id].nil?
        bb_error_hash[bb.id][datum.id] = [] if bb_error_hash[bb.id][datum.id].nil? 
        bb_error_hash[bb.id][datum.id] << I18n.t(:re_bb_too_long, :bb_name => bb.name, :max_length => bb.max_length)       
      end
    end
    bb_error_hash
  end
  
  
  
end