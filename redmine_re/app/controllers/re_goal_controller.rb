class ReGoalController < RedmineReController
  unloadable
  menu_item :re

  def new
    # redirects to edit to be more dry
    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_goal = ReGoal.find_by_id(params[:id], :include => :re_artifact_properties) || ReGoal.new
    @project ||= @re_goal.project
    # render html for tree
    @html_tree = create_tree
    if request.post?
      @re_goal.attributes = params[:re_goal]
      add_hidden_re_artifact_properties_attributes @re_goal

      flash[:notice] = t(:re_goal_saved) if save_ok = @re_goal.save

      redirect_to :action => 'edit', :id => @re_goal.id and return if save_ok
    end
  end

end
