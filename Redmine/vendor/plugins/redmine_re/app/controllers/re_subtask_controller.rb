class ReSubtaskController < ApplicationController
    unloadable

    def index
      @subtasks = ReSubtask.find(:all,
                           :joins => :re_artifact,
                           :conditions => { :re_artifacts => { :project_id => @project.id} }
      )
    end

    def new
      edit
    end

    # edit can be used for new/edit and update
    def edit
      @re_subtask = ReSubtask.find_by_id(params[:id], :include => :re_artifact) || ReSubtask.new
      @re_subtask.build_re_artifact unless @re_subtask.re_artifact

      if request.post?
        @re_subtask.attributes = params[:re_subtask]
        add_hidden_re_artifact_attributes @re_subtask.re_artifact

        flash[:notice] = 'Subtask successfully saved' unless save_ok = @re_subtask.save
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

    def show_versions
      @subtask = ReSubtask.find(params[:id] ) # :include => :re_artifact)
    end

    def change_version
      targetVersion = params[:version]
      @subtask = ReSubtask.find(params[:id])
      if(@subtask.revert_to!(targetVersion))
        flash[:notice] = 'Subtask version changed sucessfully'
      end

      redirect_to :action => 'index', :project_id => @project.id
    end

  end
