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

  validates_uniqueness_of :source_id, :scope => [:sink_id, :relation_type], :message => :re_the_specified_relation_already_exists
  validates_uniqueness_of :sink_id, :scope => :relation_type, :if => Proc.new { |rel| rel.relation_type == "parentchild" }, :message => :re_only_one_parent_allowed
  validates_presence_of :relation_type
  validates_presence_of :sink_id, :unless => Proc.new { |rel| rel.relation_type == "parentchild" }
  validates_presence_of :sink, :unless => Proc.new { |rel| rel.relation_type == "parentchild" }
  validates_presence_of :source_id
  validates_inclusion_of :relation_type, :in => RELATION_TYPES.values

  named_scope :of_project, lambda { |project|
    project_id = (project.is_a? Project) ? project.id : project
    first_join = "INNER JOIN #{ReArtifactProperties.table_name} AS source_artifacts ON source_artifacts.id = #{self.table_name}.source_id"
    second_join = "INNER JOIN #{ReArtifactProperties.table_name} AS sink_artifacts ON sink_artifacts.id = #{self.table_name}.sink_id"
    { :select => "#{self.table_name}.*", :joins => [first_join, second_join],
      :conditions => ["source_artifacts.project_id = ? AND sink_artifacts.project_id = ?", project_id, project_id] }
  }

  def self.find_all_relations_for_artifact_id(artifact_id)
    artifact = ReArtifactProperties.find(artifact_id)
    self.find_all_relations_for_artifact(artifact)
  end

  def self.find_all_relations_for_artifact(artifact)
    relations = []
    relations.concat(self.find_all_by_source_id(artifact.id))
    relations.concat(self.find_all_by_sink_id(artifact.id))
    relations.uniq
  end

  def self.relation_types
    RELATION_TYPES.values
  end

  acts_as_list # see special scope condition below

  def scope_condition()
    # each relation_type is a seperate list
    "source_id = #{source_id} AND #{connection.quote_column_name("relation_type")} = #{quote_value(self.relation_type)}"
  end

end
