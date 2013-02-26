require_dependency 'redmine/notifiable'

module NotifiablePatch
  def self.included(base)
    base.extend(ClassMethods)
    
    base.class_eval do
      # Wrap some methods
      alias_method_chain :all, :re_notifications
    end
  end

  module ClassMethods
    # Overwrites and wraps the available_filters method to add custom filters
    def all_with_re_notifications
      notifications = all_without_re_notfifications
      notifications << Notifiable.new('artifact_edited')
      notifications << Notifiable.new('artifact_added')
    end
  end
  
end

Issue.send(:include, NotifiablePatch)
