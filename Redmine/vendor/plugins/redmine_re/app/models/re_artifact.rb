class ReArtifact < ActiveRecord::Base
  unloadable

  belongs_to :superclass, :dependent => :destroy, :polymorphic => true

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  
  validates_presence_of :project, :author, :name, :artifact
  validates_uniqueness_of :name
  
end