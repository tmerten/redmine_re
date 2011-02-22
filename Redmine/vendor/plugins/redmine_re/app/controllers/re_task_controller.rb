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

  def index
    @tasks = ReTask.find(:all,
                         :joins => :re_artifact_properties,
                         :conditions => { :re_artifact_properties => { :project_id => params[:project_id]} }
    )
    render :layout => false if params[:layout] == 'false'
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

      # When new Task in order to save the subtasks and their positions you need the id of the task

      if @re_task.new_record?
        # Attributes of Subtasks delete from re_task hash in order that task can be saved(need id for parent relation to subtasks)
        subtask_attributes = params[:re_task].delete("subtask_attributes")

        @re_task.attributes = params[:re_task]
        add_hidden_re_artifact_properties_attributes @re_task

        # Task will be saved with valid attributes
        @re_task.save

        # saves subtasks and sets position
        @re_task.subtask_attributes = subtask_attributes
        #todo: flash notification if a subtask fails validation
      else
        # implicite executeion of subtask_attributes
        @re_task.attributes = params[:re_task]
        add_hidden_re_artifact_properties_attributes @re_task
      end


      flash[:notice] = 'Task successfully saved' if save_ok = @re_task.save

      redirect_to :action => 'edit', :id => @re_task.id and return if save_ok
    end
  end

  ##
  # deletes and updates the flash with either success, id not found error or deletion error
  def delete
    @re_task = ReTask.find_by_id(params[:id], :include => :re_artifact)
    if !@re_task
      flash[:error] = 'Could not find a task with id ' + params[:id] + ' to delete'
    else
      name = @re_task.re_artifact.name
      if ReTask.destroy(@re_task.id)
        flash[:notice] = 'The Task "' + name + '" has been deleted'
      else
        flash[:error] = 'The Task "' + name + '" could not be deleted'
      end
    end
    redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
  end

  ##
  # unused right now
  def show
    @re_task = ReTask.find_by_id(params[:id])
  end

  ##
  # shows all versions
  def show_versions #todo das view funktioniert
    @task = ReTask.find(params[:id] ) # :include => :re_artifact_properties)
  end

  ##
  # reverts to an older version
  def change_version
    targetVersion = params[:version]
    @task = ReTask.find(params[:id])

    if(@task.revert_to!(targetVersion))
      flash[:notice] = 'Task version changed sucessfully'
    end

    redirect_to :action => 'index', :project_id => @project.id
  end

end
