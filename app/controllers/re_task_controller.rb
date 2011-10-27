class ReTaskController < RedmineReController
  unloadable
  menu_item :re

  def edit_hook_valid_artifact_after_save params
    unless @artifact.re_subtasks.empty?
      @artifact.reload.re_subtasks
      flash.now[:notice] = t(:re_task_and_subtasks_saved)
    end
  end

end
