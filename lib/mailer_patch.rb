require_dependency 'mailer'

# Mixin for Issue Model
# Connects a Redmine Issue with an RE-Plugin Artifact
module MailerPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    #typing in class
    base.class_eval do
      unloadable
    end
  end

  module ClassMethods
    

  
  end

  module InstanceMethods
    def artifact_edited(artifact)
      logger.debug('!!!!!!!!!!!!!!! E-MAIL SEND !!!!!!!!!!!!!!!')
      artifact.recipients
      subject "[#{artifact.name}]"
      body :artifact => artifact,
           :artifact_url => url_for(:controller => 'artifact', :action => 'edit', :id => artifact)
      render_multipart('artifact_updated', body)
    end
  end
end

Mailer.send(:include, MailerPatch)
