class ReArtifactProperties < ActiveRecord::Base
  unloadable

  ARTIFACT_TYPES = { :ReGoal => 1, :ReTask => 2, :ReSubtask => 3 }
  ARTIFACT_COLOURS = {:ReGoal => '#ea6b55', :ReTask => '#ddaa88', :ReSubtask => '#bb8899'  }

  has_many :relationships_as_source,
    :order => "re_artifact_relationships.position",
    :foreign_key => "source_id",
    :class_name => "ReArtifactRelationship"

  has_many :relationships_as_sink,
    :order => "re_artifact_relationships.position",
    :foreign_key => "sink_id",
    :class_name => "ReArtifactRelationship"
    
  has_many :sinks,    :through => :relationships_as_source, :order => "re_artifact_relationships.position"
  has_many :children, :through => :relationships_as_source, :order => "re_artifact_relationships.position",
    :conditions => [ "re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:parentchild] ],
    :source => "sink"
  
  has_many :sources, :through => :relationships_as_sink,   :order => "re_artifact_relationships.position"
  has_one :parent, :through => :relationships_as_sink,
    :conditions => [ "re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:parentchild] ],
    :source => "source"

  belongs_to :artifact, :polymorphic => true #, :dependent => :destroy
  
  # TODO: Implement author and watchable module into the common fields.
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  acts_as_watchable
  

  belongs_to :project
  #belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :project, :created_by, :updated_by, :name
  validates_uniqueness_of :name

  # Should be on, but prevents subtasks from saving for now.
  #validates_numericality_of :priority, :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 50

  # Methoden
  attr_accessor :state # Als Zustand noetig fuer(observer)
 

  # TODO: Mirsad soll in Englisch schreiben.
  def revert
       #TODO neue version erstellen wenn reverted
       self.state = State::IDLE

       versionNr = self.artifact.version
       version   = self.artifact.versions.find_by_version(versionNr)

       # ReArtifactProperties attribute wiederherstellen
       self.name = version.artifact_name
       self.priority = version.artifact_priority

       self.save
    end

  # Setzt die eigenen zu Versiontabelle hinzugef�gten Spalten
  def update_extra_version_columns
     versionNr = self.artifact.version
     version   = self.artifact.versions.find_by_version(versionNr)

     version.updated_by         = User.current.id
     version.artifact_name      = self.name
     version.artifact_priority  = self.priority
     version.parent_artifact_id = self.parent_artifact_id

     version.save
  end

#  def create_new_version
#     versionNr = self.artifact.version
#     version   = self.artifact.versions.find_by_version(versionNr)
#     Rails.logger.debug("####### create new version#########1 version" + version.inspect )
#     new_version = version.clone
#     Rails.logger.debug("####### create new version#########2 version/ new version" + version.inspect + "\n" + new_version.inspect)
#
#     new_version.version = new_version.version.to_i + 1
#     #new_version.id += 1
#     Rails.logger.debug("####### create new version######### version/ new version" + version.inspect + "\n" + new_version.inspect + "\n artifact vers" + self.artifact.version.to_s)
#
#
#     self.artifact.without_revision do
#        self.artifact.version  = new_version.version
#        self.artifact.save
#     end
#     Rails.logger.debug("####### create new version######### artifact" + self.artifact.inspect)
#
#     new_version.save
#  end

  # Versioniert das Elternartifact
  def versioning_parent
     return if self.parent.nil? #Nur wenn ein parent existiert

     parent = self.parent.artifact
     parent.save  # Neue version vom parent(ohne ver�nderung von attributen)

     # gespeicherte Version zwischenspeichern
     savedParentVersion = parent.versions.last

     #--- Version mit zusatzinformation updaten ---
     # Den verursacher(child) zwischenspeichern
     savedParentVersion.versioned_by_artifact_id      = self.id
     savedParentVersion.versioned_by_artifact_version = self.artifact.version

     parent.re_artifact.update_extra_version_columns
     
     savedParentVersion.save
  end
  
  # creates a new relation of type "relation_type" or updates an existing relation
  # from "self" to the re_artifact_properties in "to".
  # (any class that acts_as_re_artifact should also work for "to".)
  #
  # see ReArtifactRelationship::TYPES.keys for valid types
  # the relation will be directed, unless you pass "false" as third argument
  #
  # returns the created relation
  def relate_to(to, relation_type, directed=true)
    raise ArgumentError, "relation_type not valid (see ReArtifactRelationship::TYPES.keys for valid relation_types)" if not ReArtifactRelationship::RELATION_TYPES.has_key?(relation_type)
    
    to = instance_checker to
    
    relation_type_no = ReArtifactRelationship::RELATION_TYPES[relation_type]
    
    # we can not give more than one parent
    if (relation_type == :parentchild) && (! to.parent.nil?) && (to.parent.id != self.id)
        raise ArgumentError, "You are trying to add a second parent to the artifact: #{to}. No ReArtifactRelationship has been created or updated."
    end
    
    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type(self.id, to.id, relation_type_no)
    # new relation    
    if relation.nil?
      self.sinks << to
      relation = self.relationships_as_source.find_by_source_id_and_sink_id self.id, to.id
    else
      if parent.nil?
        ReArtifactRelationships.delete(relation.id)
        return nil
      end
    end
 
    # update properties of new or exising relation
    relation.relation_type = relation_type_no
    relation.directed = directed
    relation.save
    
    relation
  end

  # make parent= work as expected
  # with the exception that we will return the relation not the parent!
  # (create a new parent or replace the current parent)  
  def parent=(parent)
    relation_type_no = ReArtifactRelationship::RELATION_TYPES[:parentchild]
    relation = ReArtifactRelationship.find_by_sink_id_and_relation_type(self.id, relation_type_no)

    if not relation.nil?
      # override existing relation
      if parent.nil?
        ReArtifactRelationship.delete(relation.id)
        return
      end
      parent = instance_checker parent
      relation.source_id = parent.id
      relation.save
    else
      #create new relation
      relation = parent.relate_to self, :parentchild
    end
    
    relation
  end

  # delivers the ID of the re_artifact_properties when the name of the controller and id of sub-artifact is given
    def self.get_properties_id(controllername, subartifact_id)
      @re_artifact_properties = ReArtifactProperties.find_by_artifact_type_and_artifact_id(controllername.camelize, subartifact_id)
      @re_artifact_properties.id
    end

  
  private
  
  # checks if o is of type re_artifact_properties or acts_as_artifact
  # returns o or o's re_artifact_properties
  def instance_checker(o)
    if not o.instance_of? ReArtifactProperties
      if not o.respond_to? :re_artifact_properties
        raise ArgumentError, "you can relate ReArtifactProperties to other ReArtifactProperties or a class that acts_as_artifact, only."
      end
      o = o.re_artifact_properties
    end
    o    
  end
end