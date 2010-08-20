class ReGoal < ActiveRecord::Base
  unloadable

  has_one :re_artifact, :dependent => :destroy, :as => :artifact
  accepts_nested_attributes_for :re_artifact, :allow_destroy => true

  validates_presence_of :superclass
  
end