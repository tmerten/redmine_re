##
# super controller for the redmine RE plugin
# common methods used for (almost) all redmine_re controllers go here
class RedmineReController < ApplicationController
  unloadable

  before_filter :find_project, :authorize,
                :except =>  :delegate_tree_drop

  layout 'base' # uses Redmines Base layout for the header
  menu_item :re # marks 'Requirements' (css class=re) as the selected menu item

  ##
  # find the current project either by project name (project id entered by the user) or id
  def find_project
    project_id = params[:project_id]
    return unless project_id
    begin
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  ##
  # this adds user-unmodifiable attributes to the re_artifact
  # the re_artifact is a superclass of all other artifacts (goals, tasks, etc)
  # this method should be called after initializing or loading any artifact object
  def add_hidden_re_artifact_attributes re_artifact
    author = find_current_user
    re_artifact.project_id = @project.id
    re_artifact.author_id = author.id
    re_artifact.updated_at = Time.now
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
    @jsontree += ', "txt" : "' + re_artifact.name.to_s + '"'
    @jsontree += ', "ondrop" : "my_drop"'
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

  # Launches generation of JSON-Tree for artifacts belonging to the given project
  # If artifact id is given, only the branch starting with this artifact is transformed into JSON
  # If no artifact id is given, all artifacts of the project are transformed in several JSON-trees
  def treeview
    @jsontree = ""
    artifacts = []
    if params[:id]
      # Create only one branch starting with artifact with given id if id is given
      artifacts << ReArtifact.find_by_id_and_project_id(params[:id], params[:project_id])
    else
      artifacts += ReArtifact.find_all_by_parent_artifact_id_and_project_id(nil, params[:project_id]) 
    end
    for artifact in artifacts
      render_to_json_tree(artifact)
      if (artifact != artifacts.last)
        @jsontree += ","
      end
    end
    render(:layout => false) if request.xhr?
  end
end