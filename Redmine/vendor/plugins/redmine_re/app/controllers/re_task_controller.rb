class ReTaskController < RedmineReController
  unloadable

  def index
    @tasks = ReTask.find(:all,
                         :joins => :re_artifact,
                         :conditions => { :re_artifacts => { :project_id => @project.id} }
    )
  end

  def new
    edit
  end

  # edit can be used for new/edit and update
  def edit
    @re_task = ReTask.find_by_id(params[:id], :include => :re_artifact) || ReTask.new
    @re_task.build_re_artifact unless @re_task.re_artifact

    if request.post?
      @re_task.attributes = params[:re_task]
      add_hidden_re_artifact_attributes @re_task.re_artifact
      @re_task.re_artifact.parent_artifact_id = params[:parent_id] if params[:parent_id]
      # Todo: Abklären, wo ReArtifact gespeichert wird. Geht das über re_task.save automatisch?
      flash[:notice] = 'Task successfully saved' unless save_ok = @re_task.save
      # we won't put errors in the flash, since they can be displayed in the errors object

      redirect_to :action => 'index', :project_id => @project.id and return if save_ok
    end

  end

    ##
  # deletes and updates the flash with either success, id not found error or deletion error
  def delete
    @re_task = ReTask.find_by_id(params[:id], :include => :re_artifact)
    if !@re_task
      flash[:error] = 'Could not find a task with this ' + params[:id] + ' to delete'
    else
      name = @re_task.re_artifact.name
      if ReTask.delete(@re_task.id)
        flash[:notice] = 'The Task "' + name + '" has been deleted'
      else
        flash[:error] = 'The Task "' + name + '" could not be deleted'
      end
    end
    redirect_to :action => 'index', :project_id => @project.id
  end

  ##
  # unused right now
  def show
    @re_task = ReTask.find_by_id(params[:id])
  end

  ##
  # shows all versions
  def show_versions
    @task = ReTask.find(params[:id] ) # :include => :re_artifact)
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
