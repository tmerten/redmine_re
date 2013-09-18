class ReArtifactProperties < ActiveRecord::Base
  unloadable

  #attr_accessible :artifact_type

  scope :without_projects, :conditions => ["artifact_type != ?", 'Project']
  scope :of_project, lambda { |project|
    project_id = (project.is_a? Project) ? project.id : project
    {:conditions => {:project_id => project_id}}
  }
  
  has_many :ratings, :dependent => :destroy
  
  has_many :raters, :through => :ratings, :source => :users
  has_many :comments, :as => :commented, :dependent => :destroy, :order => "created_on asc"
  has_many :realizations, :dependent => :destroy
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

  has_many :traces_as_source,
           :order => "re_artifact_relationships.position",
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type NOT IN (?)", ReArtifactRelationship::SYSTEM_RELATION_TYPES.values],
           :dependent => :destroy

  has_many :traces_as_sink,
           :order => "re_artifact_relationships.position",
           :foreign_key => "sink_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type NOT IN (?)", ReArtifactRelationship::SYSTEM_RELATION_TYPES.values],
           :dependent => :destroy

  has_one :parent_relation,
          :order => "re_artifact_relationships.position",
          :foreign_key => "sink_id",
          :class_name => "ReArtifactRelationship",
          :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pch]],
          :dependent => :destroy

  has_many :child_relations,
           :order => "re_artifact_relationships.position",
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pch]],
           :dependent => :destroy

           #######
  has_many :primary_relations,
           :order => "re_artifact_relationships.position",
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pac]],
           :dependent => :destroy
           
  has_many :actors_relations,
           :order => "re_artifact_relationships.position",
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:ac]],
           :dependent => :destroy
 
  has_many :dependency_relations,
           :order => "re_artifact_relationships.position",   
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:dep]],
           :dependent => :destroy
           
  has_many :conflict_relations,
           :order => "re_artifact_relationships.position",
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:con]],
           :dependent => :destroy
          
 has_many :rationale_relations, 
          :order => "re_artifact_relationships.position",
          :foreign_key => "source_id",
          :class_name => "ReArtifactRelationship",
          :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:rat]],
          :dependent => :destroy
          
 has_many :refinement_relations,
          :order => "re_artifact_relationships.position",
          :foreign_key => "source_id",
          :class_name => "ReArtifactRelationship",
          :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:ref]],
          :dependent => :destroy
 
 has_many :part_of_relations,
          :order => "re_artifact_relationships.position",
          :foreign_key => "source_id",
          :class_name => "ReArtifactRelationship",
          :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::RELATION_TYPES[:pof]],
          :dependent => :destroy
  
                    #####
                    
  has_many :diagram_relations,           
           :foreign_key => "source_id",
           :class_name => "ReArtifactRelationship",
           :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:dia]],
           :dependent => :destroy

  #if defined?(ConcreteDiagram) == 'constant' 
   
  has_many :related_diagrams, :through => :diagram_relations, :class_name => "ConcreteDiagram",  :source => "sink"
     
    
  has_many :sinks,    :through => :traces_as_source, :order => "re_artifact_relationships.position"
  has_many :children, :through => :child_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  ###
  has_many :primary, :through => :primary_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :actors, :through => :actors_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :dependency, :through => :dependency_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :conflict, :through => :conflict_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :rationale, :through => :rationale_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :refinement, :through => :refinement_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :part_of, :through => :part_of_relations,  :order => "re_artifact_relationships.position", :source => "sink"
  has_many :diagram, :through => :diagram_relations,  :order => "re_artifact_relationships.position", :source => "sink"

  ###
  has_many :sources,  :through => :traces_as_sink,   :order => "re_artifact_relationships.position"
  has_one  :parent,   :through => :parent_relation,  :source => "source"

  acts_as_watchable
  acts_as_attachable({:delete_permission => :edit_requirements, :view_permission => :view_requirements})

  acts_as_event(
      :title => Proc.new { |o|
        "#{l(:re_artifact)} \"#{o.name}\" #{ (o.updated_at == o.created_at) ? l(:re_was_created) : l(:re_was_updated) }."
      },
      :description => Proc.new { |o|
        "#{l(:re_artifact)} \"#{o.name}\" #{ (o.updated_at == o.created_at) ? l(:re_was_created) : l(:re_was_updated) }."
      },
      :datetime => :updated_at,
      :url => Proc.new { |o|
        {:controller => 're_artifact_properties', :action => 'show', :id => o.id}
      }
  )

  acts_as_activity_provider(
      :type => 're_artifact_properties',
      :timestamp => "#{ReArtifactProperties.table_name}.updated_at",
      :author_key => "#{ReArtifactProperties.table_name}.updated_by",
      :find_options => {:include => [:project, :user]},
      :permission => :edit_requirements
  )

  # workaround such that the a project can be deleted flawlessly from Redmine
  def destroy
    if self.artifact_type == "Project"
      relationships_as_source.each { |r| r.destroy }
      delete
    else
      super
    end
  end

  def updated_on
    updated_at
  end

  def created_on
    created_at
  end

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'created_by'
  #belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :user, :foreign_key => 'updated_by'
  belongs_to :artifact, :polymorphic => true, :dependent => :destroy
  belongs_to :responsible, :class_name => 'User', :foreign_key => 'responsible_id'

  # attributes= and artifact_attributes are overwritten to instantiate
  # the correct artifact_type and use nested attributes for re_artifact_properties
  accepts_nested_attributes_for :artifact

  def build_artifact properties, something_we_dont_know_yet
    # is build_artifact only called when the re_artifact is new?
    logger.debug properties.inspect
    # properties.re_subtask => properties.re_subtask_attributes or properties_re_subtasks_attributes 

    if self.artifact_type
      self.artifact = self.artifact_type.constantize.new(properties)
    else
      throw "ReArtifactProperties always need an ArtifactType"
    end
  end

  def attributes=(attributes = {})
    unless attributes[:artifact_type].blank?
      self.artifact_type = attributes[:artifact_type]
    end
    super
  end

  validates :name, :length => {:minimum => 3, :maximum => 100}
  validates :project, :presence => true
  validates :created_by, :presence => true
  validates :updated_by, :presence => true
  validates :parent, :presence => true, :unless => Proc.new { |a| a.artifact_type == "Project" }
  validates :artifact_type, :presence => true, :inclusion => {
      :in => %w(ReGoal ReSection ReVision ReTask ReSubtask ReVision ReWorkarea ReUserProfile ReSection ReRequirement ReScenario ReProcessword ReRational ReUseCase ReRationale Project)}

  #TODO
  #validates_associated :parent_relation
  validates :parent_relation, :presence => true, :unless => Proc.new { |a| a.artifact_type == "Project" }

  # Returns true if usr or current user is allowed to view the artifact
  def visible?(usr=nil)
    if (!usr.nil? && usr.allowed_to?(:view_requirements, self.project)) || User.current.allowed_to?(:view_requirements, self.project)
      return true
    else
      return false
    end
  end

  # Returns the users that should be notified
  def notified_users
    notified = []
    # Author and assignee are always notified unless they have been
    # locked or don't want to be notified
    notified << author if author
    notified = notified.select { |u| u.active? && u.notify_about?(self) }
    notified.uniq!
    # Remove users that can not view the issue
    notified.reject! { |user| !visible?(user) }
    notified
  end

  # Returns the email addresses that should be notified
  def recipients
    notified_users.collect(&:mail)
  end

  # Finds all artifacts that are commonly used by the supplied issues
  def self.find_all_by_common_issues(issue_array, *args)
    artifact_ids = []
    issue_array.each do |issue|
      if artifact_ids.empty?
        artifact_ids = issue.realizations.collect { |r| r.re_artifact_properties_id }
      else
        artifact_ids = artifact_ids & (issue.realizations.collect { |r| r.re_artifact_properties_id })
      end
    end
    ReArtifactProperties.find(artifact_ids, *args)
  end

  def self.available_artifact_types
    all(:group => :artifact_type, :select => :artifact_type).collect(&:artifact_type)
  end

  def position
    return parent_relation.position
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

  def siblings
    self.parent.children
  end

  def average_rating
    @value = 0.to_f
    unless self.ratings.empty?
      self.ratings.each do |rating|
        @value = @value + rating.value
      end
      @total = self.ratings.size
      @value = @value.to_f / @total.to_f
    end
    @value
  end
end
