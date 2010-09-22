class RequirementsController < RedmineReController
  unloadable

  def index
    @artifacts  = ReArtifact.find_all_by_project_id(@project.id)
    @jsontree = ''
    treeview
    @artifacts = [] if @artifacts == nil
  end

  def delegate_tree_drop
    new_parent_id = params[:new_parent_id]
    moved_artifact_id = params[:moved_artifact_id]
    child = ReArtifact.find_by_id(moved_artifact_id)
    child.parent_artifact_id = new_parent_id
    child.save!
    render :nothing => true
  end


end