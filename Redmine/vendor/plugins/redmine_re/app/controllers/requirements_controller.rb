class RequirementsController < RedmineReController
  unloadable

  def index
    @artifacts  = ReArtifact.find_all_by_project_id(@project.id)
    @artifacts = [] if @artifacts == nil
  end


  def treeviw
    # TODO: see RedmineReController, there is no parent, either

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
