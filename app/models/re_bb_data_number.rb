class ReBbDataNumber < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_text
  belongs_to :re_artifact_properties
    
end
