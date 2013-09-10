class ReArtifactRelationship < ActiveRecord::Base
  unloadable

  RELATION_TYPES = {    
    :dep => "dependency",
    :con => "conflict",
    :rat => "rationale",
    :ref => "refinement",
    :pof => "part_of"
  }
  
  SYSTEM_RELATION_TYPES = {
    :pch => "parentchild",
    :pac => "primary_actor",
    :ac =>  "actors",
    :dia => "diagram"
  }

  ALL_RELATION_TYPES =  RELATION_TYPES.merge(SYSTEM_RELATION_TYPES)
  
  INITIAL_COLORS= {
    :pch => "#0000ff",
    :dep => "#00ff00",
    :con => "#ff0000",
    :rat => "#993300",
    :ref => "#33cccc",
    :pof => "#ffcc00",
    :pac => "#999900", 
    :ac =>  "#339966",  
    :dia => "#A127F2"
  }

  # The relationship has ReArtifactProperties as source and sink 
  belongs_to :source, :class_name => "ReArtifactProperties"
  belongs_to :sink,   :class_name => "ReArtifactProperties"
  
  validates :source_id, :uniqueness => { :scope => [:sink_id, :relation_type],
    :message => :re_the_specified_relation_already_exists }

  validates :sink_id, :uniqueness => { :scope => :relation_type,
    :message => :re_only_one_parent_allowed }, :if => Proc.new { |rel| rel.relation_type == "parentchild" }
  
  validates :relation_type, :presence => true
  validates :sink_id, :presence => true, :unless => Proc.new { |rel| rel.relation_type == "parentchild" }
  validates :sink, :presence => true, :unless => Proc.new { |rel| rel.relation_type == "parentchild" || rel.relation_type == "diagram" }
  validates :source_id, :presence => true
  validates :relation_type, :inclusion => { :in => ALL_RELATION_TYPES.values }

  scope :of_project, lambda { |project|
    project_id = (project.is_a? Project) ? project.id : project
    first_join = "INNER JOIN #{ReArtifactProperties.table_name} AS source_artifacts ON source_artifacts.id = #{self.table_name}.source_id"
    second_join = "INNER JOIN #{ReArtifactProperties.table_name} AS sink_artifacts ON sink_artifacts.id = #{self.table_name}.sink_id"
    { :select => "#{self.table_name}.*", :joins => [first_join, second_join],
      :conditions => ["source_artifacts.project_id = ? AND sink_artifacts.project_id = ?", project_id, project_id] }
  }
  def self.find_all_relation_type_by_source_id(source_id)
    
    
    return self.find_by_sql("SELECT relation_type FROM re_artifact_relationships WHERE source_id =='source_id'")
    
    
    
  end

   def self.find_all_relations_for_artifact_id(artifact_id)
     relations = []
     relations.concat(self.find_all_by_source_id(artifact_id))
     relations.concat(self.find_all_by_sink_id(artifact_id))
     relations.uniq
  end

  def self.relation_types
    return [] << RELATION_TYPES.values << SYSTEM_RELATION_TYPES.values
  end

  acts_as_list # see special scope condition below

  def scope_condition()
    # define a seperate list for each source id and relation type
    "#{connection.quote_column_name("source_id")} = #{quote_value(self.source_id)}
     AND
     #{connection.quote_column_name("relation_type")} = #{quote_value(self.relation_type)}"
  end

end
