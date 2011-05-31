module StrategyProcs
  
  SAVE_OPTIONS_STRATEGY = lambda do | option_string, re_bb | 
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
end