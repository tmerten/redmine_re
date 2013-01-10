class ReGoal < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#339966"

  acts_as_re_artifact
  
end