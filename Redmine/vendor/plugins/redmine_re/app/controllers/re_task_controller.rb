class ReTaskController < RedmineReController
  unloadable
  menu_item :re

  def update_subtask_positions
    params[:subtasks].each_with_index do |id, index|
      @subtask = ReSubtask.find(id)
      @relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type(@subtask.parent.id,
                                                                                         @subtask.re_artifact_properties.id,
                                                                                         ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                          )
      @relation.position = index + 1
      @relation.save
    end
    render :nothing => true
  end

  def add_subtask
     if params[:id]
      #the subtask which link was clicked
      @re_subtask_with_clicked_link = ReSubtask.find(params[:id])
      @html_id = "subtask_drag_" + params[:id]
     else
      @html_id = "subtasks"
     end

     @add_position = params[:add_position]

     @re_subtask =  ReSubtask.new(:sub_type => 0) #,:re_artifact_properties => ReArtifactProperties.new(:project_id => @re_subtask_with_before_link.project_id, :created_by => find_current_user.id))
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

      if @re_task.new_record? # perhaps todo: first check if all subtasks are valid
        add_hidden_re_artifact_properties_attributes @re_task
        @re_task.name = params[:re_task][:name]
        @re_task.save         # subtask_attributes=   needs the id of the parent in order to change the positions of the subtasksa
      end
      @re_task.attributes = params[:re_task]
      add_hidden_re_artifact_properties_attributes @re_task

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
    if request.xhr?
      redirect_to :action => 'index', :project_id => @project.id, :layout => 'false'
    else
      redirect_to :action => 'index', :project_id => @project.id
    end

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
