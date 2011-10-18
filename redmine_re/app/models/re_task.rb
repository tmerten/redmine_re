class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  #virtual attribute
  def subtask_attributes=(subtask_attributes)
    if subtask_attributes.blank?
      return
    end

    subtask_attributes.each do |id, attributes|

        is_new = id.to_s.start_with?("new") # Every new Subtask has id = new_XYZABC

        if(is_new) #TODO : use get instance of subtask method
          subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
                                                                                       :created_by => User.current.id,
                                                                                       :updated_by => User.current.id))
          subtask.parent=self
        else
          subtask = ReSubtask.find(id)
        end

        # Get position and delete it from attributes hash
        position = attributes.delete("position")

        subtask.attributes = attributes
        if subtask.valid? # empty subtask won't be saved'
          subtask.save
          subtask.parent_relation.insert_at(position)
        end
    end
  end

  def self.sort_subtasks_attributes_by_position(subtask_attributes, project_id)
    #  returns an array of subtasks sorted by their positions

    subtasks = Array.new(subtask_attributes.size - 1)
      subtask_attributes.each do |id, attributes|
        subtask = self.get_subtask_instance_from_attributes(id, attributes, project_id)
        subtask.valid?
        subtasks[attributes[:position].to_i - 1] =  subtask
      end
      return subtasks
  end

  def self.get_subtask_instance_from_attributes(id, attributes, project_id)
    is_new = id.to_s.start_with?("new") # Every new Subtask has id = new_394834384848
    # create a subtask object with current attributes
    if is_new
      subtask =  ReSubtask.new(
        :re_artifact_properties => 
         ReArtifactProperties.new(
           :project_id => project_id,
           :created_by => User.current.id,
           :updated_by => User.current.id
         )
    )

    else
      subtask = ReSubtask.find(id)
    end

    subtask.name     = attributes[:name]
    subtask.solution = attributes[:solution]
    subtask.sub_type = attributes[:sub_type]

    return subtask
  end

end
