class ReSubtaskController < RedmineReController
  unloadable
  menu_item :re

  # The new and edit functions will be called via the RedmineReController.
  # Both methods are pretty much equal for every artifact type (goal, scenario
  # etc. ).
  #
  # If your artifact type needs special treatment uncommenct the following
  # hook method(s).
  # You find an example of how to use these hooks in the ReTaskController
  
  #def new_hook(params)
  #end

  #def edit_hook_after_artifact_initialized(params)
  #end
  
  #def edit_hook_validate_before_save(params, artifact_valid)
    # must return true, if the validation passed or false if invalid 
    # you should also attach your errors to the @artifact variable

  #  return true
  #end
  
  #def edit_hook_valid_artifact_after_save(params)
  #end
  
  #def edit_hook_invalid_artifact_cleanup(params)
  #end

  ##
  # shows all versions
  def show_versions
    @subtask = ReSubtask.find(params[:id] ) # :include => :re_artifact_properties)
    @markedVersionNr = params[:version]
  end

  ##
  # reverts to an older version
  def change_version               #TODO auch re_artifact_properties name und priority wiederherstellen dirty: in oberserver re_artifact_properties attribute immer updaten von aktueller version. momentan versuch mit notify.. siehe unten
    targetVersion = params[:version]           #TODO bei revert to neu versions record
    @subtask = ReSubtask.find(params[:id])
    @subtask.re_artifact.send(:notify, :before_revert)
    if(@subtask.revert_to!(targetVersion))
      @subtask.re_artifact.send(:notify, :after_revert)  # observer after_revert methode ausf�hren( n�tig um werte von re_artifact_properties zu reverten)
      flash[:notice] = 'Subtask version changed sucessfully'
    end
    #@subtask.re_artifact_properties.isReverting = false
    redirect_to :action => 'index', :project_id => @project.id
  end

  end
