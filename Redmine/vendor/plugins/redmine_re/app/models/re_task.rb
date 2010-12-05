class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

  #acts_as_versioned
    def subtask_attributes=(subtask_attributes)
      subtask_attributes.each do |key, value|
          if(key.to_s.start_with?("new")) # Every new Subtask has id = new394834384848
            subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
                                                                                         :created_by => User.current.id,
                                                                                         :updated_by => User.current.id))
          else
            subtask = ReSubtask.find(key)
          end
          subtask.attributes = value
          subtask.parent = self
          subtask.save
      end
    end
end
