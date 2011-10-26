require_dependency 'issue'


#Mixin for Issue Model
#Connects a Redmine Issue with an RE-Plugin Artifact


module IssuePatch

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    #typing in class
    base.class_eval do
      unloadable

      #puts base.methods
      has_many :realizations
      has_many :re_artifact_properties,  :through => :realizations, :uniq => true

    end

  end


module ClassMethods

  def tickets_with_end_overdue(project)
    #Tickets whose status should be set to closed by now!
    self.find(:all, :conditions=> ["due_date > ? AND status_id < 5 AND project_id= ?", Time.now, project.id] )
  end

  def tickets_with_start_overdue(project)
    self.find(:all, :conditions=> ["start_date < ? AND status_id < 2 AND project_id=?", Time.now, project.id])
  end

end

module InstanceMethods
end

end

Issue.send(:include, IssuePatch)