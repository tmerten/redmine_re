class ReSubtask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  SUBTASK_TYPES = { :Subtask => 0, :Variant => 1, :Problem => 2 }
  #acts_as_versioned
  #accepts_nested_attributes_for :re_artifact_properties, :allow_destroy => true

  #position in scope of parent (source)
  def position() #todo: exceptionsource or sink not in db if
    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.parent,
                                                                                       self.re_artifact_properties.id,
                                                                                       ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                     )
    return relation.position
  end

  # set position in scope of parent (source)
  def position=(position)#todo: exceptionsource or sink not in db if
    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.parent,
                                                                                       self.re_artifact_properties.id,
                                                                                       ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                     )
     relation.position = position
     relation.save
  end
end
