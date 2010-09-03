class ReArtifact < ActiveRecord::Base
  unloadable

  has_many :children,
           :class_name => "ReArtifact",
           :foreign_key => "parent_artifact_id"
  belongs_to :parent, :class_name => 'ReArtifact', :foreign_key => 'parent_artifact_id'

  belongs_to :artifact, :dependent => :destroy, :polymorphic => true

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :project, :author, :name
  validates_uniqueness_of :name
  
end