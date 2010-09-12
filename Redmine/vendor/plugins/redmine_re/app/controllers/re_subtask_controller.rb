class ReSubtaskController < RedmineReController
  unloadable

  def index
    @subtasks = ReSubtask.find(:all,
                         :joins => :re_artifact,
                         :conditions => { :re_artifacts => { :project_id => @project.id} }
    )

   
  end

  def new
    @re_subtask = ReSubtask.new
    @re_subtask.re_task_id = params[:task_id] #TODO task_id etfernen und durch re_Artifact => parent_id ersetzen  (db remove column oder migration down and up
  end

  def create
    #TODO eventuell wieder new/create/update in edit verschmelzen
    # create ReArtifact and delete key from params(to prevent HashWithIndifferentAccess Error when creating re_subtask )
    @re_artifact = ReArtifact.new(params[:re_subtask].delete(:re_artifact))
    add_hidden_re_artifact_attributes @re_artifact

    # create Subtask and add Reference to ReArtifact
    @re_subtask = ReSubtask.new(params[:re_subtask])
    @re_subtask.re_artifact = @re_artifact
    @re_subtask.re_artifact.parent_artifact_id = params[:parent_id] if params[:parent_id]
    
    # save Subtask and implicit ReArtifact
    save_ok = @re_subtask.save

    if save_ok
      flash[:notice] = 'Subtask successfully created'
      # we won't put errors in the flash, since they can be displayed in the errors object
      redirect_to :action => 'index', :project_id => @project.id and return
    end

  end

  def edit
     @re_subtask = ReSubtask.find(params[:id])
  end

   def update
     @re_subtask = ReSubtask.find(params[:id])

     #  update ReArtifact and delete key from params(to prevent HashWithIndifferentAccess Error when updating re_subtask )
     @re_subtask.re_artifact.attributes = params[:re_subtask].delete(:re_artifact)
     add_hidden_re_artifact_attributes @re_subtask.re_artifact

     # update Subtask and save ReArtifact
     update_ok = @re_subtask.update_attributes(params[:re_subtask])

     if update_ok
       flash[:notice] = 'Subtask was successfully updated.'
       # we won't put errors in the flash, since they can be displayed in the errors object
       redirect_to :action => 'index', :project_id => @project.id and return
     end
  end

  #momentan nicht verwendet:
  # edit can be used for new/edit and update
  def editbak
    @re_subtask = ReSubtask.find_by_id(params[:id], :include => :re_artifact) || ReSubtask.new
    @re_subtask.build_re_artifact unless @re_subtask.re_artifact

    # Task_id transfered with GET (CREATE)
    @re_subtask.re_task_id = params[:task_id] unless @re_subtask.id


    if request.post?
      #id wurde nicht bei re_artifact_attributs übergeben wenn vorhanden
      params[:re_subtask][:re_artifact_attributes][:id] = @re_subtask.re_artifact.id

      @re_subtask.attributes = params[:re_subtask]

      add_hidden_re_artifact_attributes @re_subtask.re_artifact

      save_ok = @re_subtask.save

      flash[:notice] = 'Subtask successfully saved' unless save_ok
      # we won't put errors in the flash, since they can be displayed in the errors object

      redirect_to :action => 'index', :project_id => @project.id and return if save_ok
    end

  end

    ##
  # deletes and updates the flash with either success, id not found error or deletion error
  def delete
    @re_subtask = ReSubtask.find_by_id(params[:id], :include => :re_artifact)
    if !@re_subtask
      flash[:error] = 'Could not find a subtask with this ' + params[:id] + ' to delete'
    else
      name = @re_subtask.re_artifact.name
      if ReSubtask.delete(@re_subtask.id)
        flash[:notice] = 'The Subtask "' + name + '" has been deleted'
      else
        flash[:error] = 'The Subtask "' + name + '" could not be deleted'
      end
    end
    redirect_to :action => 'index', :project_id => @project.id
  end

  ##
  # unused right now
  def show
    @re_subtask = ReSubtask.find_by_id(params[:id])
  end

  ##
  # shows all versions
  def show_versions
    @subtask = ReSubtask.find(params[:id] ) # :include => :re_artifact)
    @markedVersionNr = params[:version]
  end

  ##
  # reverts to an older version
  def change_version
    targetVersion = params[:version]
    @subtask = ReSubtask.find(params[:id])
    if(@subtask.revert_to!(targetVersion))
      flash[:notice] = 'Subtask version changed sucessfully'
    end

    redirect_to :action => 'index', :project_id => @project.id
  end

  end
