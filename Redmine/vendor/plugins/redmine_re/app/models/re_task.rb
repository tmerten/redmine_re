class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

  acts_as_versioned
  #accepts_nested_attributes_for :re_artifact_properties, :allow_destroy => true
end
