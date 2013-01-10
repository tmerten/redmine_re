class ReWorkarea < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#993300"

  acts_as_re_artifact
end
