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

  def new
    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_task = ReTask.find_by_id(params[:id], :include => :re_artifact_properties) || ReTask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => @project.id))
    @subtasks = []
    @re_task.children.each {|c| @subtasks << c.artifact if c.artifact_type == "ReSubtask"}
    @project ||= @re_task.project
    @html_tree = create_tree

    if request.post?
      # check validation of task and subtask attributes

      valid_task = true
      valid_subtask_attributes = true
      subtask_attributes = params[:re_task].delete(:subtask_attributes)

      ## Task validation
      @re_task.attributes = params[:re_task]
      valid_task = @re_task.valid?

      ## subtask_attributes validation
      valid_subtask_attributes = @re_task.subtasks_valid?(subtask_attributes)

      # Saving everything
      if valid_task && valid_subtask_attributes
        if @re_task.save
          # Save all subtasks
          @re_task.subtask_attributes = subtask_attributes

          flash[:notice] = t(:re_task_and_subtasks_saved)
          redirect_to :action => 'edit', :id => @re_task.id and return
        end
      else
        # Get all Subtasks sorted by their position
        @subtasks = @re_task.get_subtasks_sorted_by_position(subtask_attributes)

        # Add error to task
        # TODO: Distinguish type of error and translate
        @re_task.errors.add_to_base(t(:re_subtasks_not_valid)) unless valid_subtask_attributes
      end
    end
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
