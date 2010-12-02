class ReGoalController < RedmineReController
  unloadable

  def index
    @goals = ReGoal.find(:all,
                         :joins => :re_artifact_properties,
                         :conditions => {:re_artifact_properties => {:project_id => @project.id}}
    )
    render :layout => false if params[:layout] == 'false'
  end

  ##
  # redirects to edit to be more dry
  def new
    edit
  end

  def edit
    @re_goal = ReGoal.find_by_id(params[:id], :include => :re_artifact_properties) || ReGoal.new
     if request.get?
       render :layout => false if params[:layout] = 'false'
     end


    if request.post?

      @re_goal.attributes = params[:re_goal]
      add_hidden_re_artifact_properties_attributes @re_goal

      flash[:notice] = 'Goal successfully saved' if save_ok = @re_goal.save

      if request.xhr?
        redirect_to :action => 'index', :project_id => @project.id, :layout => 'false'
      else
        redirect_to :action => 'index', :project_id => @project.id and return if save_ok
      end
    end
  end

  ##
  # deletes and updates the flash with either success, id not found error or deletion error
  def delete
    @re_goal = ReGoal.find_by_id(params[:id], :include => :re_artifact_properties)
    if !@re_goal
      flash[:error] = 'Could not find a goal with this ' + params[:id] + ' to delete'
    else
      name = @re_goal.name
      if ReGoal.destroy(@re_goal.id)
        flash[:notice] = 'The Goal "' + name + '" has been deleted'
      else
        flash[:error] = 'The Goal "' + name + '" could not be deleted'
      end
    end
    if request.xhr?
      redirect_to :action => 'index', :project_id => @project.id, :layout => 'false'
    else
      redirect_to :action => 'index', :project_id => @project.id
    end
  end

  ##
  # unused right now
  def show
    @re_goal= ReGoal.find_by_id(params[:id])
  end

end
