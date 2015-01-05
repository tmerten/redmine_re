class ReQueriesController < RedmineReController
  unloadable
  menu_item :re

  before_filter :load_selectable_collections, :except => [:suggest_artifacts, :suggest_issues, :suggest_users,
                                                          :artifacts_bits, :issues_bits, :users_bits]
  before_filter :load_visible_queries, :except => [:suggest_artifacts, :suggest_issues, :suggest_users,
                                                   :artifacts_bits, :issues_bits, :users_bits]

  def index
    @query = ReQuery.from_filter_params(request.query_parameters)
    @query.project = @project
    load_cropped_collections
    initialize_tree_data
    if @query.set_by_params?
      @found_artifacts = ReArtifactProperties.all(:conditions => @query.conditions, :order => @query.order_string)
    else
      @found_artifacts = []
    end
    render 'query'
  end

  def show
    @query = ReQuery.visible.find(params[:id])
    @query.order = params[:order] if params[:order]
    initialize_tree_data
    load_cropped_collections

    @found_artifacts = ReArtifactProperties.all(:conditions => @query.conditions, :order => @query.order_string)
  end

  def apply
    @query = ReQuery.new(params[:re_query])
    @query.project = @project
    load_cropped_collections
    redirect_to re_queries_path(@query.to_filter_params)
  end

  def new
    @query = ReQuery.from_filter_params(params)
    @query.project = @project

    initialize_tree_data
    load_cropped_collections
  end

  def edit
    @query = ReQuery.visible.find(params[:id])
    initialize_tree_data
    load_cropped_collections
  end

  def create
    @query = ReQuery.new(params[:re_query])
    @query.project = @project
    load_cropped_collections
    initialize_tree_data
    if @query.save
      redirect_to re_query_path(@project.id, @query)
    else
      render :action => 'new'
    end
  end

  def update
    @query = ReQuery.visible.find(params[:id])
    @query.update_attributes(params[:re_query])
    
    load_cropped_collections
    if @query.save
      redirect_to re_query_path(@project.id, @query)
    else
      render :action => 'edit'
    end
  end

  def delete
    @query = ReQuery.visible.find(params[:id])
    @query.destroy
    redirect_to re_queries_path(@project.id)
  end

  # AJAX Helpers
  
  ##
  ## These helpers create a list of artifacts/issues/diagrams/whatever
  ##
  
  def suggest_artifacts
    artifacts = []
    unless params[:query].blank?
      sql = "name LIKE ?"
      sql << " AND id NOT IN (?)" unless params[:except_ids].blank?
      sql << " AND artifact_type IN (?)" unless params[:only_types].blank?
      sql << " AND artifact_type NOT IN (?)" unless params[:except_types].blank?

      conditions = [sql, "%#{params[:query]}%"]
      conditions << params[:except_ids] unless params[:except_ids].blank?
      conditions << params[:only_types] unless params[:only_types].blank?
      conditions << params[:except_types] unless params[:except_types].blank?

      artifacts = ReArtifactProperties.of_project(@project).without_projects
      artifacts = artifacts.all(:conditions => conditions, :order => 'name ASC')
      artifacts.map! do |artifact|
        artifact_to_json(artifact).merge({:highlighted_name => highlight_letters(artifact.name, params[:query])})
      end
    end    
    render :json => artifacts
  end

  def suggest_issues
    issues = []
    unless params[:query].blank?
      sql = "project_id = ? AND subject LIKE ?"
      sql << " AND id NOT IN (?)" unless params[:except_ids].blank?

      conditions = [sql, @project.id, "%#{params[:query]}%"]
      conditions << params[:except_ids] unless params[:except_ids].blank?

      issues = Issue.all(:conditions => conditions, :order => 'subject ASC')
      issues.map! do |issue|
        issue_to_json(issue).merge({:highlighted_name => highlight_letters(issue.subject, params[:query])})
      end
    end
    render :json => issues
  end

  def suggest_diagrams
    diagrams = []
    unless params[:query].blank?
      sql = "project_id = ? AND name LIKE ?"
      sql << " AND id NOT IN (?)" unless params[:except_ids].blank?

      conditions = [sql, @project.id, "%#{params[:query]}%"]
      conditions << params[:except_ids] unless params[:except_ids].blank?

      diagrams = ConcreteDiagram.all(:conditions => conditions, :order => 'name ASC')
      diagrams.map! do |diagram|
        diagram_to_json(diagram).merge({:highlighted_name => highlight_letters(diagram.name, params[:query])})
      end
    end
    render :json => diagrams
  end

  def suggest_users
    users = []
    unless params[:query].blank?
      sql = "status = ? AND (firstname LIKE ? OR lastname LIKE ? OR login LIKE ?)"
      sql << " AND id NOT IN (?)" unless params[:except_ids].blank?

      preformatted_query = "%#{params[:query]}%"
      conditions = [sql, User::STATUS_ACTIVE, preformatted_query, preformatted_query, preformatted_query]
      conditions << params[:except_ids] unless params[:except_ids].blank?

      users = User.all(:conditions => conditions, :order => 'lastname ASC, firstname ASC, login ASC')
      users.map! do |user|
        full_name = "#{user.firstname} #{user.lastname}"
        user_to_json(user).merge({:highlighted_full_name => highlight_letters(full_name, params[:query]),
                                  :highlighted_login => highlight_letters(user.login, params[:query])})
      end
    end
    render :json => users
  end
  
  ##
  ## These helpers create bit representations for one or more artifacts/issues/diagrams/whatever
  ##

  def artifacts_bits
    artifacts = ReArtifactProperties.of_project(@project).without_projects.find(params[:ids], :order => 'name ASC')
    artifacts.map! { |artifact| artifact_to_json(artifact) }
    render :json => artifacts
  end

  def issues_bits
    issues = Issue.find(params[:ids], :conditions => { :project_id => @project.id }, :order => 'subject ASC')
    issues.map! { |issue| issue_to_json(issue) }
    render :json => issues
  end

  def diagrams_bits
    diagrams = ConcreteDiagram.find(params[:ids], :conditions => { :project_id => @project.id }, :order => 'name ASC')
    diagrams.map! { |diagram| diagram_to_json(diagram) }
    render :json => diagrams
  end

  def users_bits
    users = User.find(params[:ids], :order => 'firstname ASC, lastname ASC, login ASC')
    users.map! { |user| user_to_json(user) }
    render :json => users
  end


  private

  def load_visible_queries
    @queries = ReQuery.visible.all(:order => 'name ASC')
  end

  def load_selectable_collections
    @project_artifacts = ReArtifactProperties.of_project(@project).without_projects
    @artifacts = []
    @artifact_types = @project_artifacts.available_artifact_types
    @relation_types = ReRelationtype.relation_types(@project.id, false)
    @issues = []
    @users = User.all(:conditions => ['status = ?', User::STATUS_ACTIVE],
                      :order => 'firstname ASC, lastname ASC, login ASC')
    @roles = Role.builtin(false).all(:order => 'name ASC')
    @visible_roles = if User.current.admin?
                       @roles
                     else
                       User.current.roles_for_project(@project).builtin(false).all(:order => 'name ASC')
                     end
  end

  def load_cropped_collections
    return unless @query
      
    source_artifact_ids = [@query[:source][:ids]].flatten
    sink_artifact_ids = [@query[:sink][:ids]].flatten
    artifact_ids = source_artifact_ids.concat(sink_artifact_ids).compact.uniq
    artifact_ids.delete_if {|v| v == ""} 
    @artifacts = (artifact_ids.empty?) ? [] : @project_artifacts.find(artifact_ids)

    issue_ids = [@query[:issue][:ids]].concat([@query[:issue][:ids_include]]).concat([@query[:issue][:ids_exclude]]).flatten.compact
    @issues = (issue_ids.empty?) ? [] : Issue.find(issue_ids, :conditions => { :project_id => @project.id })
  end

  def highlight_letters(str, query)
    str.gsub /(#{query})/i, '<strong>\1</strong>'
  end

  ##
  ## These private functions create json representations for a artifact/issue/diagram/whatever
  ##

  def artifact_to_json(artifact)
    underscored_artifact_type = artifact.artifact_type.underscore
    { :id => artifact.id,
      :name => artifact.name,
      :type => artifact.artifact_type,
      :type_name => l(artifact.artifact_type),
      :icon => underscored_artifact_type,
      :url => url_for(artifact) }
  end

  def issue_to_json(issue)
    { :id => issue.id,
      :subject => issue.subject,
      :url => url_for(issue) }
  end

  def diagram_to_json(diagram)    
    project = Project.find(diagram.project_id)        
    return {
      :id => diagram.id,
      :name => diagram.name,
      :url => url_for(:controller => "diagrameditor",
                      :action => 'show', :diagram_id => diagram.id,
                      :project_id => project.identifier
                      )
    }
  end

  def user_to_json(user)
    { :id => user.id,
      :login => user.login,
      :full_name => user.to_s,
      :url => url_for(user) }
  end
end