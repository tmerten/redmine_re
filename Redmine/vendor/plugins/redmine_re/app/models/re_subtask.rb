class ReSubtask < ActiveRecord::Base
  unloadable

  after_save :versioning_parent
  #after_update :update_artifact_timestamp

  acts_as_versioned
  
  has_one :re_artifact, :as => :artifact
  belongs_to :re_task

  accepts_nested_attributes_for :re_artifact, :allow_destroy => true
  
  validates_presence_of :re_artifact


  def versioning_parent
     task = self.re_task
     task.save

     savedTaskVersion = task.versions.last

     savedTaskVersion.versioned_by_artifact_id = self.re_artifact.id
     #savedTaskVersion.updated_by = #TODO find_current_user kennt er hier nicht(method missing)
     savedTaskVersion.artifact_name = task.re_artifact.name
     savedTaskVersion.artifact_priority = task.re_artifact.priority
                                          
     savedTaskVersion.save
  end

end
