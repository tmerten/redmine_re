class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

   #acts_as_versioned

  #virtual attribuite
  def subtask_attributes=(subtask_attributes)
    if subtask_attributes.blank?
      return
    end

    subtask_attributes.each do |id, attributes|

        is_new = id.to_s.start_with?("new") # Every new Subtask has id = new_394834384848
        saved = false

        if(is_new)#todo : use get instance of subtask method
          subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
                                                                                       :created_by => User.current.id,
                                                                                       :updated_by => User.current.id))
        else
          subtask = ReSubtask.find(id)
        end

        # Get position and delete it from attributes hash
        position = attributes.delete("position")

        subtask.attributes = attributes
        if subtask.valid? # empty subtask won't be saved'
          saved = subtask.save
        end

      
        if(saved)
          subtask.set_parent(self, position)
        end
    end
  end

  #  returns an array of subtasks sorted by their positions
  def get_subtasks_sorted_by_position( subtask_attributes )
      subtasks = Array.new(subtask_attributes.size - 1)
      subtask_attributes.each do |id, attributes|
        subtask = get_subtask_instance_from_attributes(id, attributes)
        subtask.valid?
        subtasks[attributes[:position].to_i - 1] =  subtask
      end
      return subtasks
  end

  def subtask_valid?(id, attributes)
    subtask = get_subtask_instance_from_attributes(id, attributes)
    is_valid = subtask.valid?
  end

  def subtasks_valid?(subtask_attributes)
    valid_subtask_attributes = true

    subtask_attributes.each do |id, attributes|
      valid = subtask_valid?(id, attributes)

      if(valid == false)
        valid_subtask_attributes = false
      end
    end

    return valid_subtask_attributes
  end

  def get_subtask_instance_from_attributes(id, attributes)
    is_new = id.to_s.start_with?("new") # Every new Subtask has id = new_394834384848

    # create a subtask object with current attributes
    if is_new
      subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id || params[:project_id],
                                                                                   :created_by => User.current.id,
                                                                                   :updated_by => User.current.id))

    else
      subtask = ReSubtask.find(id)
    end

    subtask.name     = attributes[:name]
    subtask.solution = attributes[:solution]
    subtask.sub_type = attributes[:sub_type]

    return subtask
  end

end
