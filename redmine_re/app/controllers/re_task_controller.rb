class ReTaskController < RedmineReController
  unloadable
  menu_item :re

  def delete_subtask
    id = params[:id] #id of the subtask if new subtask then it's: new_pos => new_2
    @position = params[:pos] # new_pos if new subtask otherwise pos
    is_saved_subtask = !@position.to_s.starts_with?("new")

    # delete existent subtask
    if is_saved_subtask
      @subtask = ReSubtask.find(id)

      @subtask.re_artifact_properties.destroy
      @subtask.destroy
    end

    # remove tr of the subtask

     respond_to do |format|
       format.js
     end
  end
  
  def new_hook params
    @subtasks = []
  end
  
  def edit_hook_after_artifact_initialized params
    # inifializes subtasks from database or creates an empty subtask array for
    # new task instances

    @subtasks = []
    @artifact.children.each {|c| @subtasks << c.artifact if c.artifact_type == "ReSubtask"}
  end
  
  def edit_hook_validate_before_save(params, artifact_valid)
    # validates subtasks and recreates a subtask array from what has
    # been submitted in the last post
    
    subtask_attributes = params[:subtask_attributes]
    #valid_subtask_attributes = @artifact.subtasks_valid?(subtask_attributes)
    
    @subtasks = ReTask.sort_subtasks_attributes_by_position(subtask_attributes, @project.id)
    valid_subtasks = true
    for st in @subtasks
      valid_subtasks = false unless st.valid?   
    end
    @artifact.errors.add_to_base(t(:re_subtasks_not_valid)) unless valid_subtasks
    
    return valid_subtasks
  end
  
  def edit_hook_valid_artifact_after_save params
    # saves the subtasks and rewrites flash message to include the subtasks
    
    subtask_attributes = params[:subtask_attributes]
    @artifact.subtask_attributes = subtask_attributes
    flash[:notice] = t(:re_task_and_subtasks_saved)
  end

  def show_versions #todo das view funktioniert
    # shows all versions
    @task = ReTask.find(params[:id] ) # :include => :re_artifact_properties)
  end

  def change_version
    # reverts to an older version
    targetVersion = params[:version]
    @task = ReTask.find(params[:id])

    if(@task.revert_to!(targetVersion))
      flash[:notice] = 'Task version changed sucessfully'
    end

    redirect_to :action => 'index', :project_id => @project.id
  end

end
