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
      @subtask.destroy
    end

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
    @subtasks = @artifact.re_subtasks
  end

  def edit_hook_validate_before_save(params, artifact_valid)
    # validates subtasks and recreates a subtask array from what has
    # been submitted in the last post
    valid = true
    subtasks_posted = params[:subtask_attributes]

    logger.debug("########## #{subtasks_posted.inspect}")
    unless subtasks_posted.empty?
      subtasks_posted.each do |sp|
        logger.debug("########## #{sp.inspect}")
        id = sp[0]
        if id.starts_with? "new"
          st = ReSubtask.new
          st.attributes = sp[1]
        else
          st = ReSubtask.find(id)
        end
        #@subtasks << st
        valid = false unless st.valid?
      end
    end
    return valid
  end

  def edit_hook_valid_artifact_after_save params
    flash[:notice] = t(:re_task_and_subtasks_saved) unless @subtasks.empty?
  end

end
