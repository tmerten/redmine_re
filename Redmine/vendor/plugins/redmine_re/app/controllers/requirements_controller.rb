class RequirementsController < RedmineReController
  unloadable

  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::JavaScriptHelper


  def index
    @artifacts  = ReArtifact.find_all_by_project_id(@project.id)
    @artifacts = [] if @artifacts == nil
    @jsontree = "["
    artifacts = []
    if params[:id]
      # Create only one branch starting with artifact with given id if id is given
      artifacts << ReArtifact.find_by_id_and_project_id(params[:id], @project.id)
    else
      artifacts += ReArtifact.find_all_by_parent_artifact_id_and_project_id(nil, @project.id)
    end
    for artifact in artifacts
      render_to_json_tree(artifact)
      if (artifact != artifacts.last)
        @jsontree += ","
      end
    end
    @jsontree += "]"
  end

  def delegate_tree_drop
    new_parent_id = params[:new_parent_id]
    moved_artifact_id = params[:moved_artifact_id]
    child = ReArtifact.find_by_id(moved_artifact_id)
    child.parent_artifact_id = new_parent_id
    child.save!
    render :nothing => true
  end

  ##
  # this methods renders any re_artifact
  # as a tree
  # --
  # TODO: re_artifact has no child(ren)! think of a sound solution. Hints:Next line
  # * one could use a document structure (see Unicase) to sort artifacts in a tree
  # * one could use a fixed (maybe even variable) structure to display tree-like stuff
  #  * e.g. Workarea -> Task -> Subtask
  # * one could use (I should refactor "one could use a") a pre-definable parent-child-model for automatically sorting
  #   artifacts
  # --> first solution: Each re_artifact can have a child of any type. This is implemented as a basic version.
  # Later on one can restrict which artifact can have which kind of children (maybe even by the help of a
  # configuration file.
  # ++
  def render_to_json_tree(re_artifact)
    @jsontree += '{'
    @jsontree += '"id" : "' + re_artifact.id.to_s + '"'
    @jsontree += ', "txt" : "' + re_artifact.name.to_s
    #@jsontree += '<a href="http://gmx.de">x</a>' # this won't work! only onclick event works!
    @jsontree += '"'
    #@jsontree += ', "ondrop" : "tree_node_drop"'

    #@jsontree += ', "onclick" : "tree_node_click(' + re_artifact.id.to_s + ')"'
    # it did not work, when specifying a full function call with arguments!

    # like this it works
    @jsontree += ', "onclick" : "tree_node_click"'
    
    @jsontree += ', "img" : "' + re_artifact.artifact_type.to_s.underscore.concat('.gif" ')
    if (!re_artifact.children.empty?)
      @jsontree += ', "items" : ['
      for child in re_artifact.children
        render_to_json_tree(child)
        if (child != re_artifact.children.last)
          @jsontree += ','
        end
      end
      @jsontree += ']'
    end
    @jsontree += '}'
  end


end