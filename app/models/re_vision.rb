class ReVision < ActiveRecord::Base
  unloadable
  
  INITIAL_COLOR="#00ff00"
  
  acts_as_re_artifact
  
end
