require_dependency 'mailer'

# Mixin for Issue Model
# Connects a Redmine Issue with an RE-Plugin Artifact
module MailerPatch
  def self.included(base)
    #base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    #typing in class
    #base.class_eval do
    #  unloadable
    #end
  end

  #module ClassMethods
  #end

  module InstanceMethods
    def artifact_add(artifact)
      redmine_headers('Project' => artifact.project.identifier,
                      'Artifact-Id' => artifact.id,
                      'Artifact-Author' => artifact.author.login)
      #redmine_headers('Artifact-Watcher' => ... if issue.assigned_to

      message_id artifact
      @author = artifact.author
      @re_artifact_properties = artifact
      recipients = artifact.watcher_recipients
      mail :to => recipients,
        :subject => "[#{artifact.project.name} - ##{artifact.id}] #{artifact.name}"      
    end
    
    def artifact_edit(artifact, newest_comment)
      redmine_headers('Project' => artifact.project.identifier,
                      'Artifact-Id' => artifact.id,
                      'Artifact-Author' => artifact.author.login)
      #redmine_headers('Artifact-Watcher' => ... if issue.assigned_to

      message_id artifact
      @re_artifact_properties = artifact
      @comment = newest_comment

      recipients = artifact.watcher_recipients
      mail :to => recipients,
        :subject => "[#{artifact.project.name} - ##{artifact.id}] #{artifact.name}"    
    end    
  end
end

Mailer.send(:include, MailerPatch)
