class ReSubtaskController < RedmineReController
  unloadable
  menu_item :re

  def new
    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_subtask = ReSubtask.find_by_id(params[:id], :include => :re_artifact_properties) || ReSubtask.new
    @project ||= @re_subtask.project

    @html_tree = create_tree

    if request.post?
      @re_subtask.attributes = params[:re_subtask]
      add_hidden_re_artifact_properties_attributes @re_subtask

      flash[:notice] = t(:re_subtask_saved, :name => @re_subtask.name) if save_ok = @re_subtask.save

      redirect_to :action => 'edit' , :id => @re_subtask.id and return if save_ok
    end
  end

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
