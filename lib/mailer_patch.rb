require_dependency 'mailer'

module MailerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end


  module InstanceMethods
    def artifact_add(artifact)
      redmine_headers('Project' => artifact.project.identifier,
                      'Artifact-Id' => artifact.id,
                      'Artifact-Author' => artifact.author.login)
                      
      message_id artifact

      @re_artifact_properties = artifact
      @author = artifact.author
      @artifact_url = url_for(:controller => 're_artifact_properties', :action => 'show', :id => artifact.id)

      recipients = artifact.recipients    
      cc =  artifact.watcher_recipients - recipients

      @created_by_user = User.find(artifact.created_by)
      
      mail :to => recipients, :cc => cc,
        :subject => "[#{artifact.project.name} - ##{artifact.id}] #{artifact.name}"      
    end
    
    def artifact_edit(artifact, newest_comment)
      redmine_headers('Project' => artifact.project.identifier,
                      'Artifact-Id' => artifact.id,
                      'Artifact-Author' => artifact.author.login)

      message_id artifact
      
      recipients = artifact.recipients    
      cc =  artifact.watcher_recipients - recipients

      @re_artifact_properties = artifact
      @author = artifact.author
      @comment = newest_comment
      
      @artifact_url = url_for(:controller => 're_artifact_properties', :action => 'show', :id => artifact.id)

      @updated_by_user = User.find(artifact.updated_by)
      
           
      mail :to => recipients, :cc => cc,
        :subject => "[#{artifact.project.name} - ##{artifact.id}] #{artifact.name}"    
    end    
  end
end

Mailer.send(:include, MailerPatch)
