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

    #sort by issue due next
    openartifacts.each do |artifact|
      artifact.issues.sort!{|a,b| a.due_date <=> b.due_date}
    end
    openartifacts.sort!{|a,b| a.issues.first.due_date<=>b.issues.first.due_date}
  end

end
