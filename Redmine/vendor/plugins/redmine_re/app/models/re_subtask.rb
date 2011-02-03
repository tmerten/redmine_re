class ReSubtask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  SUBTASK_TYPES = { :Subtask => 0, :Variant => 1, :Problem => 2 }
  #acts_as_versioned
  #accepts_nested_attributes_for :re_artifact_properties, :allow_destroy => true

end
