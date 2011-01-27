class ReGoal < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  #acts_as_versioned
  #accepts_nested_attributes_for :re_artifact_properties, :allow_destroy => true
end