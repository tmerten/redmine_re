class ReUserProfile < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#ff99cc"

  acts_as_re_artifact
end
