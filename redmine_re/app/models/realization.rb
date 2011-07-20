class Realization < ActiveRecord::Base


  belongs_to :issue
  belongs_to :re_artifact_properties


    #an artifact is open iff one of the corresponding tickets is open
  def self.open_artifacts
    artifacts_with_issue = ReArtifactProperties.find(:all, :conditions => 'id in (select distinct re_artifact_properties_id from realizations)')

    openartifacts=[]

    artifacts_with_issue.each do |artifact|
      has_open_issue = false
      artifact.issues.each do |issue|
        if issue.status.to_s!="Closed"
          has_open_issue = true
        end
      end
      if has_open_issue == true
        openartifacts << artifact
      end
    end
    openartifacts


  end

  def self.openartifacts_by_due_date
    artifacts = open_artifacts

      #sort by issue due next
    artifacts.each do |artifact|
      artifact.issues.sort! { |a, b| a.due_date <=> b.due_date }
    end
    artifacts.sort! { |a, b| a.issues.first.due_date<=>b.issues.first.due_date }
  end

  def self.openartifacts_todo
    artifacts = open_artifacts
    artifacts.delete_if { |artifact|
      del = true;
      artifact.issues.each do |issue|
        if issue.assigned_to_id.blank? && issue.status_id < 5
          del = false
        end
      end
      del
    }

    artifacts.sort! do |a, b|
      self.artifact_done_ratio(b)<=>self.artifact_done_ratio(a)
    end
    artifacts

  end

  

  def self.artifact_done_ratio(artifact)
    progress = 0
    artifact.issues.each do |issue|
      progress+=(issue.status_id < 5 ? issue.done_ratio : 100)
    end
    progress/artifact.issues.count
  end


end
