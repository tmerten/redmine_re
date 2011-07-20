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

  def tickets_with_end_overdue
    #Tickets whose status should be set to closed by now!
    self.find(:all, :conditions=> ["due_date > ? AND status_id < 5", Time.now] )
  end

  def tickets_with_start_overdue
    self.find(:all, :conditions=> ["start_date < ? AND status_id < 2", Time.now])
  end

end

module InstanceMethods
end

end

Issue.send(:include, IssuePatch)