class ReSubtask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  SUBTASK_TYPES = { :Subtask => 0, :Variant => 1, :Problem => 2 }
  #acts_as_versioned
end
