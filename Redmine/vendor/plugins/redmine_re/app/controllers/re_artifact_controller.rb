class ReArtifactController < RedmineReController
  unloadable


  def edit
    redirect 'edit'
  end

  def delete
    redirect 'delete'
  end

  def redirect action
    @re_artifact = ReArtifact.find_by_id(params[:id])

    if @re_artifact.nil?
      render :template => 'error', :status => 500, :id => params[:id]
    else
      @project_id = params[:project_id]
      @redirect_id = @re_artifact.artifact_id
      @redirect_controller = @re_artifact.artifact_type.underscore

      logger.info("Redirecting from ReArtifact (name=" + @re_artifact.name + ", id="+ @re_artifact.id.to_s +
              ") to instance (id=" + @redirect_id.to_s + " ,controller=" + @redirect_controller.to_s)


      redirector = { :controller => @redirect_controller, :action => action, :id => @redirect_id, :project_id => @project_id }
      redirector[:layout] = 'false' if request.xhr?

      redirect_to redirector
    end
  end
end