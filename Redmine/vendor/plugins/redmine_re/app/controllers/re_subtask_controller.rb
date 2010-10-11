class ReSubtaskController < RedmineReController
  unloadable

  def index
    @subtasks = ReSubtask.find(:all,
                         :joins => :re_artifact,
                         :conditions => { :re_artifacts => { :project_id => @project.id} }
    )
    render :layout => false if params[:layout] == 'false'
  end

  def new
    edit #TODO re_task_id attribut löschen(zurück migrieren vor versionierung)
  end

  # edit can be used for new/edit and update
  def edit
      #if request.get?
        # Parameter id contains id of ReArtifact, not of ReSubtask as it should be
        # This has to be changed here as it is not possible to build
        # a dynamic Ajax-Updater with data from clicked tree-element
        re_artifact_id = params[:id]
        @re_artifact = ReArtifact.find_by_id(re_artifact_id)
        params[:id] = @re_artifact.artifact_id
      #end
      @re_subtask = ReSubtask.find_by_id(params[:id], :include => :re_artifact) || ReSubtask.new
      @re_subtask.build_re_artifact unless @re_subtask.re_artifact
      # If no parent_id is transmitted, we don't create a new artifact but edit one
      # Therefore, a valid parent_artifact_id is existent and has to be read out
      if request.get?
        if params[:parent_id] == nil
          params[:parent_id] = @re_subtask.re_artifact.parent_artifact_id
        end
      end

      if request.post?
        # Params Hash anpassen

        ## 1. Den Key re_artifact in re_artifact_attributes kopieren und löschen
        ### Params Hash aktuell BSP: "re_task"=>{"re_artifact"=>{"name"=>"TaskArtifactEditTesterV3", "priority"=>"777777"}
        params[:re_subtask][:re_artifact_attributes] = params[:re_subtask].delete(:re_artifact)

        ### Params Hash aktuell BSP:"re_task"=>{"re_artifact_attributes"=>{"name"=>"TaskArtifactEditTesterV3", "priority"=>"777777"}

        ## 2. Den Key re_artifact_attributes die id hinzufügen, weil sonst bei Edit neues ReArtifact erzeugt wird da keine Id gefunden wird
        params[:re_subtask][:re_artifact_attributes][:id] = @re_subtask.re_artifact.id
        #render :text => 're_artifact_attribute_hash: ' + params[:re_subtask][:re_artifact_attributes].to_s
        ### Params Hash aktuell BSP:"re_task"=>{"re_artifact_attributes"=>{ "id"=>37,"name"=>"TaskArtifactEditTesterV3", "priority"=>"777777"}

        # dies funktioniert nun (nur mit re_artifact_attributes key halt)
        @re_subtask.attributes = params[:re_subtask]
        add_hidden_re_artifact_attributes @re_subtask.re_artifact
        @re_subtask.re_artifact.parent_artifact_id = params[:parent_id] if params[:parent_id] and @re_subtask.new_record?
        # Todo: Abklären, wo ReArtifact gespeichert wird. Geht das über re_task.save automatisch?
        flash[:notice] = 'Subtask successfully saved' unless save_ok = @re_subtask.save
        # we won't put errors in the flash, since they can be displayed in the errors object

        redirect_to :action => 'index', :project_id => @project.id, :layout => 'false' and return if save_ok
      end
    end


    ##
  # deletes and updates the flash with either success, id not found error or deletion error
  def delete
    @re_subtask = ReSubtask.find_by_id(params[:id], :include => :re_artifact)
    if !@re_subtask
      flash[:error] = 'Could not find a subtask with this ' + params[:id] + ' to delete'
    else
      # might be replaced by :dependend => :nullify in artifact model
      name = @re_subtask.re_artifact.name
      if ReSubtask.destroy(@re_subtask.id)
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
  def change_version               #TODO auch re_artifact name und priority wiederherstellen dirty: in oberserver re_artifact attribute immer updaten von aktueller version. momentan versuch mit notify.. siehe unten
    targetVersion = params[:version]           #TODO bei revert to neu versions record
    @subtask = ReSubtask.find(params[:id])
    @subtask.re_artifact.send(:notify, :before_revert)
    if(@subtask.revert_to!(targetVersion))
      @subtask.re_artifact.send(:notify, :after_revert)  # observer after_revert methode ausführen( nötig um werte von re_artifact zu reverten)
      flash[:notice] = 'Subtask version changed sucessfully'
    end
    #@subtask.re_artifact.isReverting = false
    redirect_to :action => 'index', :project_id => @project.id
  end

  end
