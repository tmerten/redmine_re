class ReScenario < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#00ccff"
  
  acts_as_re_artifact
  
end
