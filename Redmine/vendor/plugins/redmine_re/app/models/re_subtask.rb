class ReSubtask < ActiveRecord::Base
  unloadable

  acts_as_versioned
  
  has_one :re_artifact, :as => :artifact
  belongs_to :re_task

  accepts_nested_attributes_for :re_artifact, :allow_destroy => true
  
  validates_presence_of :re_artifact
end
