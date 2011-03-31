class ReUserProfileController < RedmineReController
  unloadable
  def index
  
    @re_user_profiles = ReUserProfile.find(:all,
                         :joins => :re_artifact_properties,
                         :conditions => {:re_artifact_properties => {:project_id => @project.id}}
    )
    render :layout => false if params[:layout] == 'false'
  end

  def new
    # redirects to edit to be more dry

    redirect_to :action => 'edit', :project_id => params[:project_id]
  end

  def edit
    @re_user_profile = ReUserProfile.find_by_id(params[:id], :include => :re_artifact_properties) || ReUserProfile.new
    @project ||= @re_user_profile.project
    
    # render html for tree
    @html_tree = create_tree
    
    if request.post?
      @re_user_profile.attributes = params[:re_user_profile]
      add_hidden_re_artifact_properties_attributes @re_user_profile

      flash[:notice] = t(:re_user_profile_saved) if save_ok = @re_user_profile.save

      redirect_to :action => 'edit', :id => @re_user_profile.id and return if save_ok
    end
  end

  def delete
  # deletes and updates the flash with either success, id not found error or deletion error
    @re_user_profile = ReUserProfile.find_by_id(params[:id], :include => :re_artifact_properties)

    if !@re_user_profile
      flash[:error] = t(:re_user_profile_not_found, :id => params[:id])
    else
      name = @re_user_profile.name
      if ReUserProfile.destroy(@re_user_profile.id)
        flash[:notice] = t(:re_user_profile_deleted, :name => name)
      else
        flash[:error] = t(:re_user_profile_not_deleted, :name => name)
      end
    end
    redirect_to :controller => 'requirements', :action => 'index', :project_id => @project.id
  end

end