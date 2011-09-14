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
  has_many :re_bb_data_artifact_selection, :dependent => :destroy
  
  #validates_uniqueness_of :source, :scope => [:sink, :relation_type]
  validates_inclusion_of :relation_type, :in => RELATION_TYPES.values

  def valid_type?
    RELATION_TYPES.has_value?(self.relation_type)
  end
  
  acts_as_list :scope => :source
end