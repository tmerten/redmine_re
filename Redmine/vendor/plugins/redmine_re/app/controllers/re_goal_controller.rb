class ReGoalController < RedmineReController
  unloadable

  def index
    @goals = ReGoal.find(:all,
                         :joins => :re_artifact,
                         :conditions => {:re_artifacts => {:project_id => @project.id}}
    )
    # (faster but less readable) alternative using a left join as an example
    #@goals = ReGoal.find_by_sql('select G.id, G.description from re_goals G LEFT JOIN re_artifacts A on G.id = A.artifact_id where A.artifact_type = "ReGoal" and A.project_id =1  ')
  end

  ##
  # redirects to edit to be more dry
  def new
    edit
  end

  ##
  # edit can be used for new/edit and update
  def edit
    @re_goal = ReGoal.find_by_id(params[:id], :include => :re_artifact) || ReGoal.new
    @re_goal.re_artifact = ReArtifact.new unless @re_goal.re_artifact

    if request.post?
      # Todo: Author-id to be extracted from session
      params["re_goal"]["re_artifact_attributes"].merge Hash["project_id" => params[:id], "author_id" => '1']
      @re_goal.attributes = params[:re_goal]  # due to nested attributes the new ReArtifact is updated as well
      add_hidden_re_artifact_attributes @re_goal.re_artifact

      flash[:notice] = 'Goal successfully saved' if save_ok = @re_goal.save
      # we won't put save errors in the flash, since they are displayed in the errors object

      redirect_to :action => 'index', :project_id => @project.id and return if save_ok
    end

  end

  ##
  # deletes and updates the flash with either success, id not found error or deletion error
  def delete
    @re_goal = ReGoal.find_by_id(params[:id], :include => :re_artifact)
    if !@re_goal
      flash[:error] = 'Could not find a goal with this ' + params[:id] + ' to delete'
    else
      name = @re_goal.re_artifact.name
      if ReGoal.delete(@re_goal.id)
        flash[:notice] = 'The Goal "' + name + '" has been deleted'
      else
        flash[:error] = 'The Goal "' + name + '" could not be deleted'
      end
    end
    redirect_to :action => 'index', :project_id => @project.id
  end

  ##
  # unused right now
  def show
    @re_goal= ReGoal.find_by_id(params[:id])
  end

end
