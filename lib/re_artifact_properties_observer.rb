class ReArtifactPropertiesObserver < ActiveRecord::Observer
  def after_create(artifact)
    Mailer.deliver_artifact_edited(issue) #if Setting.notified_events.include?('issue_added')
  end
  
  def after_save(artifact)
    Mailer.deliver_artifact_edited(artifact) #if Setting.notified_events.include?('issue_added')
  end
end
