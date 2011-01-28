class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

   #acts_as_versioned

  #virtual attribuite
  def subtask_attributes=(subtask_attributes)
    subtask_attributes.each do |id, attributes|

        is_new = id.to_s.start_with?("new") # Every new Subtask has id = new_394834384848
        if(is_new)
          subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
                                                                                       :created_by => User.current.id,
                                                                                       :updated_by => User.current.id))
        else
          subtask = ReSubtask.find(id)
        end

        # Get position and delete it from attributes hash
        position = attributes.delete("position")

        subtask.attributes = attributes
        subtask.parent = self
        saved = subtask.save

        if(saved)
           subtask.position = position
        end
    end
  end
end
