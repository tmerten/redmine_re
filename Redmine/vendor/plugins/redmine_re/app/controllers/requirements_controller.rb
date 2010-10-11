class RequirementsController < RedmineReController
  unloadable

  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::JavaScriptHelper


  def index
    @artifacts  = ReArtifact.find_all_by_project_id(@project.id)
    @artifacts = [] if @artifacts == nil
    # jsontree will start with project as one and only node
    @jsontree = '[ {"id": "project_' + @project.id.to_s + '", "txt" : "' + @project.name.to_s + '", "items" : ['
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
    @jsontree += "] } ]"
  end

  ##
  # The following method is called via JavaScript Tafeltree by an ajax request.
  # It transmits the drops done in the tree to the database in order to last
  # longer than the next refresh of the browser.
  def delegate_tree_drop
    new_parent_id = params[:new_parent_id]
    moved_artifact_id = params[:moved_artifact_id]
    child = ReArtifact.find_by_id(moved_artifact_id)
    if new_parent_id.index('project') != nil
      # Element is dropped under root node which is the project new parent-id has to become nil.
      child.parent_artifact_id = nil
    else
      # Element is dropped under other artifact
      child.parent_artifact_id = new_parent_id
    end
    child.save!
    render :nothing => true
  end

  ##
  # The following method is called via JavaScript Tafeltree by an ajax update request.
  # It transmits the call to the according controller which should render the detail view
  def delegate_tree_node_click
    artifact = ReArtifact.find_by_id(params[:id])
    redirect_to url_for :controller => params[:artifact_controller], :action => 'edit', :id => params[:id], :parent_id => artifact.parent_artifact_id, :project_id => artifact.project_id
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
    @jsontree += ', "txt" : "' + re_artifact.name.to_s    # for tests: + re_artifact.id.to_s + ' parent: ' + re_artifact.parent_artifact_id.to_s
    #@jsontree += '<a href="http://gmx.de">x</a>' # this won't work! only onclick event works!
    @jsontree += '"'
    #@jsontree += ', "ondrop" : "tree_node_drop"'

    #@jsontree += ', "onclick" : "tree_node_click(' + re_artifact.id.to_s + ')"'
    # it did not work, when specifying a full function call with arguments!

    # like this it works
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

  # first tries to enable a contextmenu in artifact tree
  def context_menu
    @artifact =  ReArtifact.find_by_id(params[:id])
    @subartifact_controller = @artifact.artifact_type.to_s.underscore
    @back = params[:back_url] || request.env['HTTP_REFERER']

    render :layout => false
  end


end