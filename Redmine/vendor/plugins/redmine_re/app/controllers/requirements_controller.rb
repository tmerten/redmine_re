class RequirementsController < RedmineReController
  unloadable

  def index
    @artifacts  = ReArtifact.find_all_by_project_id(@project.id)
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


  def treeviw
    # TODO: see RedmineReController, there is no parent, either
    # TODO: Klaeren, warum wir diese Funktion brauchen. Imme läuft es ueber den redmine_re_controller!
    re_artifacts = ReArtifact.find_all_by_parentid(nil)
    @jsontree = ""
    for re_artifact in re_artifacts
      render_to_json_tree(re_artifact)
      if (re_artifact != re_artifacts.last)
        @jsontree += ","
      end
    end
  end
end
