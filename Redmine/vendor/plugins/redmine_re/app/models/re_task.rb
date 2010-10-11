class ReTask < ActiveRecord::Base
  unloadable
  
   acts_as_versioned

   has_one :re_artifact, :as => :artifact, :dependent => :destroy
   has_many :re_subtasks, :dependent => :nullify

   accepts_nested_attributes_for :re_artifact, :allow_destroy => true

  
   validates_presence_of :re_artifact

end
