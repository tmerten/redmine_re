class ReArtifactRelationship < ActiveRecord::Base
  unloadable

  # The relationship has a certain type
  RELATION_TYPES = { :parentchild => 1, :dependency => 2, :conflict => 4 }
    
  # The relationship has ReArtifactProperties as source or sink 
  belongs_to :source, :class_name => "ReArtifactProperties"
  belongs_to :sink,   :class_name => "ReArtifactProperties"

  acts_as_list :scope => :sink
end