class ReBbDataLink < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_link
  belongs_to :re_artifact_properties
  
end
