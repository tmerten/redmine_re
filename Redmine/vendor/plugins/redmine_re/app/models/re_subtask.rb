class ReSubtask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

  SUBTASK_TYPES = { :Subtask => 0, :Variant => 1, :Problem => 2 }
  #acts_as_versioned
  #accepts_nested_attributes_for :re_artifact_properties, :allow_destroy => true

  #position in scope of parent (source)
  def position #todo: exceptionsource or sink not in db if
    raise ArgumentError, "relation_type not valid (see ReArtifactRelationship::TYPES.keys for valid relation_types)" if not ReArtifactRelationship::RELATION_TYPES.has_key?(relation_type)

    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.parent.id,
                                                                                       self.re_artifact_properties.id,
                                                                                       ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                     )
    return relation.position
  end

    def position=(source, sink, relation_type)#todo: exceptionsource or sink not in db if
    raise ArgumentError, "relation_type not valid (see ReArtifactRelationship::TYPES.keys for valid relation_types)" if not ReArtifactRelationship::RELATION_TYPES.has_key?(relation_type)

    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( source.id,
                                                                                       sink.id,
                                                                                       relation_type
                                                                                     )
    return relation.position
  end
end
