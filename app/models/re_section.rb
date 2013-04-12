class ReSection < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#c0c0c0"
  
  acts_as_re_artifact
end
