class ReArtifactProperties < ActiveRecord::Base
  unloadable

  cattr_accessor :artifact_types
  
  RELATION_TYPES = {
  	:parentchild => 1,
  	:dependency => 2,
  	:conflict => 3
    #:rationale => 4,
    #:refinement => 5,
    #:part_of => 6
	}
	
  has_many :relationships_as_source,
    :order => "re_artifact_relationships.position",
    :foreign_key => "source_id",
    :class_name => "ReArtifactRelationship",
    :dependent => :destroy

  has_many :relationships_as_sink,
    :order => "re_artifact_relationships.position",
    :foreign_key => "sink_id",
    :class_name => "ReArtifactRelationship",
    :dependent => :destroy
    
  has_many :sinks,    :through => :relationships_as_source, :order => "re_artifact_relationships.position"
  has_many :children, :through => :relationships_as_source, :order => "re_artifact_relationships.position",
    :conditions => [ "re_artifact_relationships.relation_type = ?", RELATION_TYPES[:parentchild] ],
    :source => "sink"
  
  has_many :sources, :through => :relationships_as_sink,   :order => "re_artifact_relationships.position"
  has_one :parent, :through => :relationships_as_sink,
    :conditions => [ "re_artifact_relationships.relation_type = ?", RELATION_TYPES[:parentchild] ],
    :source => "source"

  has_many :re_bb_data_texts
  has_many :re_bb_data_selections

  belongs_to :artifact, :polymorphic => true #, :dependent => :destroy
  
  
  after_destroy :destroy_artifact
  
  def destroy_artifact
    artifact.destroy unless artifact.nil?
  end
    
  acts_as_event :title => Proc.new {|o| "#{l(:re_artifact)} \"#{o.name}\" #{ (o.updated_at == o.created_at)? l(:re_was_created) : l(:re_was_updated) }."},
  :description => Proc.new {|o| "#{l(:re_artifact)} \"#{o.name}\" #{ (o.updated_at == o.created_at)? l(:re_was_created) : l(:re_was_updated) }."},
    :datetime => :updated_at,
    :url => Proc.new {|o| {:controller => 're_artifact_properties', :action => 'edit', :id => o.id}}
  
  acts_as_activity_provider :type => 're_artifact_properties',
    :timestamp => "#{ReArtifactProperties.table_name}.updated_at",
    :author_key => "#{ReArtifactProperties.table_name}.updated_by",
    :find_options => {:include => [:project, :user] },
    :permission => :edit_requirements
    
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :user, :foreign_key => 'updated_by'

  # TODO: Implement author and watchable module into the common fields.
  #acts_as_watchable
  
  
  validates_presence_of :project,    :message => l(:re_artifact_properties_validates_presence_of_project)
  validates_presence_of :created_by, :message => l(:re_artifact_properties_validates_presence_of_created_by)
  validates_presence_of :updated_by, :message => l(:re_artifact_properties_validates_presence_of_updated_by)
  validates_presence_of :name,       :message => l(:re_artifact_properties_validates_presence_of_name)

  #validates_uniqueness_of :name, :message => l(:re_artifact_properties_validates_uniqueness_of_name)

  # Should be on, but prevents subtasks from saving for now.
  #validates_numericality_of :priority, :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 50

  # Methods
  attr_accessor :state # Needed to simulate the state for observer
  
  after_save :check_for_and_set_parent
  after_destroy :delete_wiki_page
  
  def check_for_and_set_parent
    if self.parent.nil? and self.artifact_type != 'Project'
      set_parent(ReArtifactProperties.find_by_project_id_and_artifact_type(self.project_id, "Project"), 1)
    end
  end
  
  def revert
    #TODO create new version if reverted
    self.state = State::IDLE

    versionNr = self.artifact.version
    version   = self.artifact.versions.find_by_version(versionNr)

    # re-create ReArtifactProperties attribute
    self.name = version.artifact_name
    self.priority = version.artifact_priority

    self.save
  end

  def update_extra_version_columns
    # puts own columns
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

  def versioning_parent
    # versions the parent artifact
    return if self.parent.nil?

    parent = self.parent.artifact
    parent.save
    
    # temporary save parent
    savedParentVersion = parent.versions.last
    
    # save the updating child
    savedParentVersion.versioned_by_artifact_id      = self.id
    savedParentVersion.versioned_by_artifact_version = self.artifact.version
    
    parent.re_artifact.update_extra_version_columns
    
    savedParentVersion.save
  end
  
  def relate_to(to, relation_type, directed=true)
    # creates a new relation of type "relation_type" or updates an existing relation
    # from "self" to the re_artifact_properties in "to".
    # (any class that acting as ReArtifact should also work for "to".)
    #
    # see ReArtifactRelationship::TYPES.keys for valid types
    # the relation will be directed, unless you pass "false" as third argument
    #
    # returns the created relation
    raise ArgumentError, "relation_type not valid (see ReArtifactRelationship::TYPES.keys for valid relation_types)" if not RELATION_TYPES.has_key?(relation_type)
    
    to = instance_checker to
    
    relation_type_no = RELATION_TYPES[relation_type]
    # we can not give more than one parent
    if (relation_type == :parentchild) && (! to.parent.nil?) && (to.parent.id != self.id)
        raise ArgumentError, "You are trying to add a second parent to the artifact: #{to}. No ReArtifactRelationship has been created or updated."
    end
    
    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type(self.id, to.id, relation_type_no)

    # new relation    
    if relation.nil?
      relation = ReArtifactRelationship.new(:source_id => self.id, :sink_id => to.id)
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

  def set_parent(parent, position = 1)
    # sets the parent using either the spcified or the last position
    # will return the relation not the parent!
    # creates a new parent or replaces the current parent
    relation_type_no = RELATION_TYPES[:parentchild]
    
    children = gather_children
    parent = instance_checker(parent)

    raise ArgumentError, "The parent may not be self" if self.eql? parent
    raise ArgumentError, "The parent may not be within the children" if children.include? parent
    
    relation = ReArtifactRelationship.find_by_sink_id_and_relation_type(self.id, relation_type_no)

    unless relation.nil?
      # delete existing relation
      if parent.nil?
        raise ArgumentError "At the moment we always need to set a parent"
        return
      end
      
      # relocate parent
      relation.remove_from_list
      relation.source_id = parent.id
      relation.save(true)
      relation.insert_at position
    else
      #create new relation
      relation = parent.relate_to self, :parentchild
      relation.insert_at position
    end
    relation
  end

  def self.get_properties_id(controllername, subartifact_id)
    # delivers the ID of the re_artifact_properties when the name of the controller and id of sub-artifact is given
    @re_artifact_properties = ReArtifactProperties.find_by_artifact_type_and_artifact_id(controllername.camelize, subartifact_id)
    @re_artifact_properties.id
  end

    # set position in scope of parent (source)
  def position=(position)
    raise ArgumentError, "For the current re_artifact_properties object #{self} exist no parent-relation in the database" if not self.parent(true)
    raise ArgumentError, "The current re_artifact_properties object #{self} is not in the database" if not self.id

    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type(
      self.parent(true).id,
      #needs true because: http://www.elevatedcode.com/articles/2007/03/16/rails-association-proxies-and-caching/
      # "By default, active record only load associations the first time you use them.
      # After that, you can reload them by passing true to the association"
      self.id,
      RELATION_TYPES[:parentchild]
    )
    relation.position = position
    relation.save
  end

  def position()
    #position in scope of parent (source)
    raise ArgumentError, "For the current re_artifact_properties object #{self} exist no parent-relation in the database" if not self.parent(true)
    raise ArgumentError, "The current re_artifact_properties object #{self} is not in the database" if not self.id

    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.parent(true).id,
      self.id,
      RELATION_TYPES[:parentchild]
    )
    return relation.position
  end

  def delete_wiki_page
    wiki_page_name = "#{self.id}_#{self.artifact_type}"
    wiki_page = WikiPage.find_by_title(wiki_page_name)
    wiki_page.destroy if wiki_page
  end
  
  def gather_children
    # recursively gathers all children for the given artifact
    #
    children = Array.new
    children.concat self.children
    return children if self.children.empty?
    for child in children
      children.concat child.gather_children
    end
    children
  end
  
  private
  
  # checks if o is of type re_artifact_properties or acts_as_artifact
  # returns o or o's re_artifact_properties
  def instance_checker(o)
    if not o.instance_of? ReArtifactProperties
      if not o.respond_to? :re_artifact_properties
        raise ArgumentError, "You can relate ReArtifactProperties to other ReArtifactProperties or a class that acts_as_artifact, only."
      end
      o = o.re_artifact_properties
    end
    o    
  end
end