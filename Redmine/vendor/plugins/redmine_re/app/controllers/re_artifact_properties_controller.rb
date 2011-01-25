class ReArtifactPropertiesController < RedmineReController
  unloadable
  menu_item :re


  def edit
    redirect 'edit'
  end

  def delete
    redirect 'delete'
  end

  def redirect action
    @re_artifact_properties = ReArtifactProperties.find_by_id(params[:id])

    if @re_artifact_properties.nil?
      render :template => 'error', :status => 500, :id => params[:id]
    else
      @project_id = params[:project_id]
      @redirect_id = @re_artifact_properties.artifact_id
      @redirect_controller = @re_artifact_properties.artifact_type.underscore

      logger.info("Redirecting from ReArtifactProperties (name=" + @re_artifact_properties.name + ", id="+ @re_artifact_properties.id.to_s +
              ") to instance (id=" + @redirect_id.to_s + " ,controller=" + @redirect_controller.to_s)


      redirector = { :controller => @redirect_controller, :action => action, :id => @redirect_id, :project_id => @project_id }
      redirector[:layout] = 'false' if request.xhr?

      redirect_to redirector
    end
  end
end