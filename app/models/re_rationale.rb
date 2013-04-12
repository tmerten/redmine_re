class ReRationale < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#FFA733"
  
  acts_as_re_artifact
  
end
