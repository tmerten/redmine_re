class ReBbDataArtifactSelection < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_artifact_selection
  belongs_to :re_artifact_properties
  belongs_to :re_artifact_relationship
   
end
