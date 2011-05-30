class ReBbDataSelection < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_selection
  belongs_to :re_artifact_properties
  belongs_to :re_bb_option_selection
   
end
