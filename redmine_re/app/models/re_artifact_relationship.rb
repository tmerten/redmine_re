class ReArtifactRelationship < ActiveRecord::Base
  unloadable

  RELATION_TYPES = {
  	:pch => "parentchild",
  	:dep => "dependency",
  	:con => "conflict",
    :rat => "rationale",
    :ref => "refinement",
    :pof => "part_of"
	}
  
  # The relationship has ReArtifactProperties as source or sink 
  belongs_to :source, :class_name => "ReArtifactProperties"
  belongs_to :sink,   :class_name => "ReArtifactProperties"
  
  #validates_uniqueness_of :source, :scope => [:sink, :relation_type]
  validates_inclusion_of :relation_type, :in => RELATION_TYPES.values
  
  acts_as_list :scope => :source
end