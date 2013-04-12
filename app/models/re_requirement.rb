class ReRequirement < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#ffcc00"
  
  acts_as_re_artifact
  
end
