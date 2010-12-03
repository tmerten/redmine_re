class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

  #acts_as_versioned
  
    def subtask_attributes=(subtask_attributes)
      subtask_attributes.each do |key, value|
          if(key.to_s.start_with?("new")) # Every new Subtask has id = new394834384848
            subtask =  ReSubtask.new#TODO:  set project_id created by and updated by.. in order to pass validation (:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id, :created_by => session[:user_id]))
          else
            subtask = ReSubtask.find(key)
          end
          subtask.attributes = value
          subtask.parent = self
          subtask.save
      end
    end
end
