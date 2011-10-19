class ReArtifactProperties < ActiveRecord::Base
  unloadable

  cattr_accessor :artifact_types
  ajaxful_rateable :stars => 10, :allow_update => false#, :dimensions => [:first]
  has_many :realizations
  has_many :comments, :as => :commented, :dependent => :destroy
  has_many :issues, :through => :realizations, :uniq => true

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

  has_one :parent_relation,
    :order => "re_artifact_relationships.position",
    :foreign_key => "sink_id",
    :class_name => "ReArtifactRelationship",
    :conditions => [ "re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:pch] ]
    # not need to put :dependent => :destroy, since it will be destroyed through relationships_as_source

  has_many :child_relations,
    :order => "re_artifact_relationships.position",
    :foreign_key => "source_id",
    :class_name => "ReArtifactRelationship",
    :conditions => [ "re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:pch] ]
    # not need to put :dependent => :destroy, since it will be destroyed through relationships_as_sink

  has_many :sinks,    :through => :relationships_as_source, :order => "re_artifact_relationships.position"
  has_many :children, :through => :child_relations, :order => "re_artifact_relationships.position", :source => "sink"

  has_many :sources, :through => :relationships_as_sink,   :order => "re_artifact_relationships.position"
  has_one :parent, :through => :parent_relation, :source => "source"
  #acts_as_list :scope => "parent_relation.parent_id", :order => "parent_relation.position"

  has_many :re_bb_data_texts, :dependent => :delete_all
  has_many :re_bb_data_selections, :dependent => :delete_all
  has_many :re_bb_data_artifact_selections, :dependent => :delete_all

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
  belongs_to :artifact, :polymorphic => true, :dependent => :destroy

  acts_as_watchable
  
  validates_presence_of :project,    :message => l(:re_artifact_properties_validates_presence_of_project)
  validates_presence_of :created_by, :message => l(:re_artifact_properties_validates_presence_of_created_by)
  validates_presence_of :updated_by, :message => l(:re_artifact_properties_validates_presence_of_updated_by)
  validates_presence_of :name,       :message => l(:re_artifact_properties_validates_presence_of_name)
  validates_presence_of :parent,     :message => l(:re_artifact_properties_validates_presence_of_parent), :unless => Proc.new { |a| a.artifact_type == "Project }

  after_destroy :delete_wiki_page

  def self.get_properties_id(controllername, subartifact_id)
    # delivers the ID of the re_artifact_properties when the name of the controller and id of sub-artifact is given
    @re_artifact_properties = ReArtifactProperties.find_by_artifact_type_and_artifact_id(controllername.camelize, subartifact_id)
    @re_artifact_properties.id
  end

  def position
    return parent_relation.position
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
