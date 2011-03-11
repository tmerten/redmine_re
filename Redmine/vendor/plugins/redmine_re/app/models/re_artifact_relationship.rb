class ReArtifactRelationship < ActiveRecord::Base
  unloadable

  # The relationship has ReArtifactProperties as source or sink 
  belongs_to :source, :class_name => "ReArtifactProperties"
  belongs_to :sink,   :class_name => "ReArtifactProperties"

  acts_as_list :scope => :source
end