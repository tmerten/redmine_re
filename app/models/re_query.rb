###############
### Filters ###
###############

class ReFilter
  attr_reader :query

  def initialize(query)
    raise ArgumentError.new unless query
    @query = query
  end

  def self.filter_name
    # TODO Filter Name can be used to create filter form fields automatically
    raise NotImplementedError.new
  end

  def self.filter_type
    raise NotImplementedError.new
  end

  def value
    raise NotImplementedError.new
  end

  def mode
    raise NotImplementedError.new
  end

  def conditions
    raise NotImplementedError.new
  end

  protected
  def inner_sql(options = {})
    sql = %{SELECT #{ReArtifactProperties.table_name}.id
            FROM #{ReArtifactProperties.table_name}}

    [options[:joins]].flatten.compact.each do |join|
      sql << " INNER JOIN " + join
    end

    unless options[:conditions].blank?
      sql << " WHERE "
      if options[:conditions].is_a? Array
        sql << options[:conditions].join(' AND ')
      else
        sql << options[:conditions]
      end
    end
    sql
  end

  # Helpers
  def collection_operator
    case mode
      when 'contains'
        "IN"
      when 'not_contains'
        "NOT IN"
      else
        nil
    end
  end

  # String matching helper method
  def string_operator
    case mode
      when 'equals'
        "="
      when 'not_equals'
        "!="
      when 'contains'
        "LIKE"
      when 'not_contains'
        "NOT LIKE"
      else
        nil
    end
  end

  # String matching helper method
  def stringified_value
    return "%#{value}%" if %w(contains not_contains).include? mode
    value
  end

  def numerified_values
    value.map(&:to_i)
  end

  # Simplified usage of complex inner SQL queries
  # The inner query has to explicitly select the id column of ReArtifactProperties
  def wrap_container_sql(inner_sql, invert = false)
    sql = "#{ReArtifactProperties.table_name}.id"
    sql << " NOT" if invert
    sql << " IN (#{inner_sql})"
    sql
  end
end

###############################
### Source Artifact Filters ###
###############################

class ReSourceIdsFilter < ReFilter
  def value
    query.source[:ids]
  end

  def mode
    query.source[:ids_mode]
  end

  def conditions
    operator = collection_operator
    return nil if !operator or value.blank?
    ["#{ReArtifactProperties.table_name}.id #{operator} (?)", numerified_values]
  end
end

class ReSourceNameFilter < ReFilter
  def value
    query.source[:name]
  end

  def mode
    query.source[:name_mode]
  end

  def conditions
    operator = string_operator
    return nil if !operator or value.blank?
    ["#{ReArtifactProperties.table_name}.name #{operator} ?", stringified_value]
  end
end

class ReSourceTypesFilter < ReFilter
  def value
    query.source[:types]
  end

  def mode
    query.source[:types_mode]
  end

  def conditions
    operator = collection_operator
    return nil if !operator or value.blank?
    ["#{ReArtifactProperties.table_name}.artifact_type #{operator} (?)", value]
  end
end

class ReSourceUserIdsFilter < ReFilter
  def table_attr
    raise NotImplementedError.new
  end

  def conditions
    if mode == 'is_me' or mode == 'contains'
      contains_sql(false)
    elsif mode == 'is_not_me' or mode == 'not_contains'
      contains_sql(true)
    else #any
      nil
    end
  end

  private
  def contains_sql(invert)
    return nil if value.blank?
    sql = "#{ReArtifactProperties.table_name}.#{table_attr}"
    sql << " NOT" if invert
    sql << " IN (?)"
    [sql, numerified_values]
  end
end

class ReSourceCreatorIdsFilter < ReSourceUserIdsFilter
  def value
    if mode == 'is_me' or mode == 'is_not_me'
      [User.current.id]
    else
      query.source[:creator_ids]
    end
  end

  def mode
    query.source[:creator_ids_mode]
  end

  def table_attr
    'created_by'
  end
end

class ReSourceMaintainerIdsFilter < ReSourceUserIdsFilter
  def value
    if mode == 'is_me' or mode == 'is_not_me'
      [User.current.id]
    else
      query.source[:maintainer_ids]
    end
  end
  def mode
    query.source[:maintainer_ids_mode]
  end
  def table_attr
    'updated_by'
  end
end

class ReSourceRoleIdsFilter < ReFilter
  def table_attr
    raise NotImplementedError.new
  end

  def conditions
    case mode
      when 'contains'
        contains_sql(false)
      when 'not_contains'
        contains_sql(true)
      else
        nil
    end
  end

  private
  def contains_sql(invert)
    return nil if value.blank?
    inner_sql = inner_sql(:joins => custom_joins, :conditions => "#{Role.table_name}.id IN (?)")
    [wrap_container_sql(inner_sql, invert), numerified_values]
  end

  def custom_joins
    ["#{Member.table_name}     ON #{Member.table_name}.user_id       = #{ReArtifactProperties.table_name}.#{table_attr}",
     "#{MemberRole.table_name} ON #{MemberRole.table_name}.member_id = #{Member.table_name}.id",
     "#{Role.table_name}       ON #{Role.table_name}.id              = #{MemberRole.table_name}.role_id"]
  end
end

class ReSourceCreatorRoleIdsFilter < ReSourceRoleIdsFilter
  def value
    query.source[:creator_role_ids]
  end
  def mode
    query.source[:creator_role_ids_mode]
  end
  def table_attr
    'created_by'
  end
end

class ReSourceMaintainerRoleIdsFilter < ReSourceRoleIdsFilter
  def value
    query.source[:maintainer_role_ids]
  end
  def mode
    query.source[:maintainer_role_ids_mode]
  end
  def table_attr
    'updated_by'
  end
end

#############################
### Sink Artifact Filters ###
#############################

class ReSinkFilter < ReFilter
  protected
  def sink_scoped_sql(inner_sql = nil)
    %{SELECT #{ReArtifactRelationship.table_name}.source_id
      FROM #{ReArtifactRelationship.table_name}
      WHERE #{ReArtifactRelationship.table_name}.sink_id IN (#{inner_sql || '?'})}
  end
end

class ReSinkIdsFilter < ReSinkFilter
  def value
    query.sink[:ids]
  end

  def mode
    query.sink[:ids_mode]
  end

  def conditions
    case mode
      when 'some'
        exists_sql(false)
      when 'none'
        exists_sql(true)
      when 'contains'
        contains_sql(false)
      when 'not_contains'
        contains_sql(true)
      else #any
        nil
    end
  end

  private
  def exists_sql(invert)
    inner_sql = %{SELECT #{ReArtifactRelationship.table_name}.*
                  FROM #{ReArtifactRelationship.table_name}
                  WHERE #{ReArtifactRelationship.table_name}.sink_id = #{ReArtifactProperties.table_name}.id}
    sql = "EXISTS (#{inner_sql})"
    sql = "NOT " + sql if invert
    [sql]
  end

  def contains_sql(invert)
    return nil if value.blank?
    [wrap_container_sql(sink_scoped_sql, invert), numerified_values]
  end
end

class ReSinkNameFilter < ReSinkFilter
  def value
    query.sink[:name]
  end

  def mode
    query.sink[:name_mode]
  end

  def conditions
    operator = string_operator
    return nil if !operator or value.blank?
    inner_sql = inner_sql(:conditions => "#{ReArtifactProperties.table_name}.name #{operator} ?")
    [wrap_container_sql(sink_scoped_sql(inner_sql)), stringified_value]
  end
end

class ReSinkTypesFilter < ReSinkFilter
  def value
    query.sink[:types]
  end

  def mode
    query.sink[:types_mode]
  end

  def conditions
    operator = collection_operator
    return nil if !operator or value.blank?
    #inner_sql = inner_sql(:conditions => "#{ReArtifactProperties.table_name}.artifact_type #{operator} (?)")
    inner_conditions = "#{ReArtifactProperties.table_name}.artifact_type #{operator} (?)"
    [wrap_container_sql(sink_scoped_sql(inner_conditions)), value]
  end
end

class ReSinkRelationTypesFilter < ReSinkFilter
  def value
    query.sink[:relation_types]
  end

  def mode
    query.sink[:relation_types_mode]
  end

  def conditions
    operator = collection_operator
    return nil if !operator or value.blank?
    inner_sql = %{SELECT #{ReArtifactRelationship.table_name}.source_id
                  FROM #{ReArtifactRelationship.table_name}
                  WHERE #{ReArtifactRelationship.table_name}.relation_type #{operator} (?)}
    [wrap_container_sql(inner_sql), value]
  end
end

class ReSinkUserIdsFilter < ReSinkFilter
  def table_attr
    raise NotImplementedError.new
  end

  def conditions
    if mode == 'is_me' or mode == 'contains'
      contains_sql(false)
    elsif mode == 'is_not_me' or mode == 'not_contains'
      contains_sql(true)
    else #any
      nil
    end
  end

  private
  def contains_sql(invert)
    return nil if value.blank?
    #inner_sql = inner_sql(:conditions => inner_conditions)
    [wrap_container_sql(sink_scoped_sql(inner_conditions), invert), numerified_values]
  end

  def inner_conditions
    %{SELECT #{ReArtifactProperties.table_name}.id
      FROM #{ReArtifactProperties.table_name}
      WHERE #{ReArtifactProperties.table_name}.#{table_attr} IN (?)}
  end
end

class ReSinkCreatorIdsFilter < ReSinkUserIdsFilter
  def value
    if mode == 'is_me' or mode == 'is_not_me'
      [User.current.id]
    else
      query.sink[:creator_ids]
    end
  end

  def mode
    query.sink[:creator_ids_mode]
  end

  def table_attr
    'created_by'
  end
end

class ReSinkMaintainerIdsFilter < ReSinkUserIdsFilter
  def value
    if mode == 'is_me' or mode == 'is_not_me'
      [User.current.id]
    else
      query.sink[:maintainer_ids]
    end
  end

  def mode
    query.sink[:maintainer_ids_mode]
  end

  def table_attr
    'updated_by'
  end
end

class ReSinkRoleIdsFilter < ReSinkFilter
  def table_attr
    raise NotImplementedError.new
  end

  def conditions
    if mode == 'is_me' or mode == 'contains'
      contains_sql(false)
    elsif mode == 'is_not_me' or mode == 'not_contains'
      contains_sql(true)
    else #any
      nil
    end
  end

  private
  def contains_sql(invert)
    return nil if value.blank?
    #inner_sql = inner_sql(:conditions => inner_conditions)
    [wrap_container_sql(sink_scoped_sql(inner_conditions), invert), numerified_values]
  end

  def inner_conditions
    %{SELECT #{ReArtifactProperties.table_name}.id
      FROM #{ReArtifactProperties.table_name}
      WHERE #{ReArtifactProperties.table_name}.#{table_attr} IN (
        SELECT #{Member.table_name}.user_id
        FROM #{Member.table_name}
        INNER JOIN #{MemberRole.table_name} ON #{MemberRole.table_name}.member_id = #{Member.table_name}.id
        WHERE #{MemberRole.table_name}.role_id IN (?)
      )}
  end
end

class ReSinkCreatorRoleIdsFilter < ReSinkRoleIdsFilter
  def value
    query.sink[:creator_role_ids]
  end

  def mode
    query.sink[:creator_role_ids_mode]
  end

  def table_attr
    'created_by'
  end
end

class ReSinkMaintainerRoleIdsFilter < ReSinkRoleIdsFilter
  def value
    query.sink[:maintainer_role_ids]
  end

  def mode
    query.sink[:maintainer_role_ids_mode]
  end

  def table_attr
    'updated_by'
  end
end

#####################
### Issue Filters ###
#####################

class ReIssueFilter < ReFilter
  protected
  def issue_scoped_sql(inner_sql = nil)
    %{SELECT #{Realization.table_name}.re_artifact_properties_id
      FROM #{Realization.table_name}
      WHERE #{Realization.table_name}.issue_id IN (#{inner_sql || '?'})}
  end
end

class ReIssueIdsFilter < ReIssueFilter
  def value
    query.issue[:ids]
  end

  def mode
    query.issue[:ids_mode]
  end

  def conditions
    case mode
      when 'some'
        exists_sql(false)
      when 'none'
        exists_sql(true)
      when 'contains'
        contains_sql(false)
      when 'not_contains'
        contains_sql(true)
      else
        nil
    end
  end

  def table_attr
    raise NotImplementedError.new
  end

  private
  def exists_sql(invert)
    inner_sql = %{SELECT #{Realization.table_name}.*
                  FROM #{Realization.table_name}
                  WHERE #{Realization.table_name}.re_artifact_properties_id = #{ReArtifactProperties.table_name}.id}
    sql = "EXISTS (#{inner_sql})"
    sql = "NOT " + sql if invert
    [sql]
  end

  def contains_sql(invert)
    return nil if value.blank?
    [wrap_container_sql(issue_scoped_sql, invert), numerified_values]
  end
end

class ReIssueNameFilter < ReIssueFilter
  def value
    query.issue[:name]
  end

  def mode
    query.issue[:name_mode]
  end

  def conditions
    operator = string_operator
    return nil if !operator or value.blank?
    [wrap_container_sql(issue_scoped_sql(inner_conditions(operator))), stringified_value]
  end

  private
  def inner_conditions(operator)
    %{SELECT #{Issue.table_name}.id
      FROM #{Issue.table_name}
      WHERE #{Issue.table_name}.subject #{operator} ?}
  end
end

class ReIssueUserIdsFilter < ReIssueFilter
  def table_attr
    raise NotImplementedError.new
  end

  def conditions
    if mode == 'is_me' or mode == 'contains'
      contains_sql(false)
    elsif mode == 'is_not_me' or mode == 'not_contains'
      contains_sql(true)
    else #any
      nil
    end
  end

  private
  def contains_sql(invert)
    return nil if value.blank?
    [wrap_container_sql(issue_scoped_sql(inner_conditions), invert), numerified_values]
  end

  def inner_conditions
    %{SELECT #{Issue.table_name}.id
      FROM #{Issue.table_name}
      WHERE #{Issue.table_name}.#{table_attr} IN (?)}
  end
end

class ReIssueAuthorIdsFilter < ReIssueUserIdsFilter
  def value
    if mode == 'is_me' or mode == 'is_not_me'
      [User.current.id]
    else
      query.issue[:author_ids]
    end
  end

  def mode
    query.issue[:author_ids_mode]
  end

  def table_attr
    'author_id'
  end
end

class ReIssueAssigneeIdsFilter < ReIssueUserIdsFilter
  def value
    if mode == 'is_me' or mode == 'is_not_me'
      [User.current.id]
    else
      query.issue[:assignee_ids]
    end
  end

  def mode
    query.issue[:assignee_ids_mode]
  end

  def conditions
    case mode
      when 'some'
        exists_sql(false)
      when 'none'
        exists_sql(true)
      else
        super
    end
  end

  def table_attr
    'assigned_to_id'
  end

  private
  def exists_sql(invert)
    inner_sql = %{SELECT #{Realization.table_name}.re_artifact_properties_id
                  FROM #{Realization.table_name}
                  INNER JOIN #{Issue.table_name} ON #{Issue.table_name}.id = #{Realization.table_name}.issue_id
                  WHERE #{Issue.table_name}.assigned_to_id IS #{invert ? '' : 'NOT '}NULL}
    [wrap_container_sql(inner_sql)]
  end
end


class ReIssueRoleIdsFilter < ReIssueFilter
  def table_attr
    raise NotImplementedError.new
  end

  def conditions
    case mode
      when 'contains'
        contains_sql(false)
      when 'not_contains'
        contains_sql(true)
      else
        nil
    end
  end

  private
  def contains_sql(invert)
    operator = collection_operator
    return nil if !operator or value.blank?
    [wrap_container_sql(issue_scoped_sql(inner_conditions), invert), numerified_values]
  end

  def inner_conditions
    %{SELECT #{Issue.table_name}.id
      FROM #{Issue.table_name}
      WHERE #{Issue.table_name}.#{table_attr} IN (
        SELECT #{Member.table_name}.user_id
        FROM #{Member.table_name}
        INNER JOIN #{MemberRole.table_name} ON #{MemberRole.table_name}.member_id = #{Member.table_name}.id
        WHERE #{MemberRole.table_name}.role_id IN (?)
      )}
  end
end

class ReIssueAuthorRoleIdsFilter < ReIssueRoleIdsFilter
  def value
    query.issue[:author_role_ids]
  end

  def mode
    query.issue[:author_role_ids_mode]
  end

  def table_attr
    'author_id'
  end
end

class ReIssueAssigneeRoleIdsFilter < ReIssueRoleIdsFilter
  def value
    query.issue[:assignee_role_ids]
  end

  def mode
    query.issue[:assignee_role_ids_mode]
  end

  def table_attr
    'assigned_to_id'
  end
end

####################
### Query Column ###
####################

class ReQueryColumn
  include Redmine::I18n
  attr_reader :name, :value, :sort

  def initialize(name, options = {}, &block)
    @name = name.to_s
    @label = options[:label]
    @sort = (options.key?(:sort) ? options[:sort] : false)
    @value = block
  end

  def label
    return @name unless @label
    return l(@label) if @label.is_a? Symbol
    @label
  end
end

#############
### Query ###
#############

class ReQuery < ActiveRecord::Base
  unloadable

  VISIBILITY = {
    :public => 'is_public',
    :me => 'for_me',
    :roles => 'for_roles'
  }

  # Columns for results
  @@available_columns = [ ReQueryColumn.new('id', :label => :re_artifact_id, :sort => true) do |artifact|
                            artifact.id
                          end,
                          ReQueryColumn.new('name', :label => :re_artifact_name, :sort => true) do |artifact|
                            %{<span class="icon #{artifact.artifact_type.underscore}">#{artifact.name}</span>}
                          end,
                          ReQueryColumn.new('type', :label => :re_artifact_type) do |artifact|
                            l(artifact.artifact_type.underscore)
                          end,
                          ReQueryColumn.new('updated_at', :label => :re_updated_at, :sort => true) do |artifact|
                            artifact.updated_at
                          end ]
  cattr_reader :available_columns

  def self.sortable_available_columns
    @@available_columns.select { |column| column.sort }
  end

  @@default_order = { :column => 'name', :direction => 'asc' }
  cattr_reader :default_order

  @@available_filters = { :source => [ ReSourceIdsFilter, ReSourceNameFilter, ReSourceTypesFilter,
                                       ReSourceCreatorIdsFilter, ReSourceCreatorRoleIdsFilter,
                                       ReSourceMaintainerIdsFilter, ReSourceMaintainerRoleIdsFilter ],
                          :sink => [ ReSinkIdsFilter, ReSinkNameFilter, ReSinkTypesFilter, ReSinkRelationTypesFilter,
                                     ReSinkCreatorIdsFilter, ReSinkCreatorRoleIdsFilter, ReSinkMaintainerIdsFilter,
                                     ReSinkMaintainerRoleIdsFilter ],
                          :issue => [ ReIssueIdsFilter, ReIssueNameFilter, ReIssueAuthorIdsFilter,
                                      ReIssueAuthorRoleIdsFilter, ReIssueAssigneeIdsFilter,
                                      ReIssueAssigneeRoleIdsFilter ],
                          :order => nil }
  cattr_reader :available_filters

  # Model Relationships
  belongs_to :project
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  has_and_belongs_to_many :visible_roles, :class_name => 'Role', :join_table => 're_queries_roles',
                                          :foreign_key => 'query_id', :association_foreign_key => 'role_id'

  # Scopes
  scope :visible, lambda { visibility_condition(User.current) }
  scope :visible_for, lambda { |user| visibility_condition(user) }

  # Filter serialization
  @@available_filters.keys.each do |filter_group|
    serialize filter_group
  end

  # Validation  
  validates :name, :presence => true, :allow_nil => true
  validates :name, :uniqueness => true

  # Hooks
  before_validation :assign_creator, :on => :create 
  before_validation :assign_maintainer, :on => :create
  before_validation :repair_visibility
  before_save :clear_unassigned_visible_roles

  def initialize(attributes = nil)
    super(attributes)
    @set_by_params = false
  end

  def visible_role_ids
    @visible_role_ids || visible_roles.map(&:id)
  end

  def visible_role_ids=(values)
    if values.blank?
      @visible_role_ids = nil
      self.visible_roles.delete_all
    else
      @visible_role_ids = values.map(&:to_i)
      self.visible_roles = Role.find(@visible_role_ids)
    end
  end

  # Creates a new non-persistent query
  def self.from_filter_params(params)
    query = new

    @@available_filters.keys.each do |filter_group|
      query.send :"#{filter_group}=", params[filter_group]
    end
    
    unless query.source[:ids].nil?
      query.source[:ids].delete_if {|v| v == ""} 
    
    end
    
    unless query.source[:builder].nil?
        
        query.source.delete(:builder)  
    
    end

    unless query.source[:namespace].nil?
        
        query.source.delete(:namespace)  
    
    end

    unless query.sink[:builder].nil?
        
        query.sink.delete(:builder)  
    
    end

    unless query.sink[:namespace].nil?
        
        query.sink.delete(:namespace)  
    
    end

    unless query.issue[:builder].nil?
        
        query.issue.delete(:builder)  
    
    end

    unless query.issue[:namespace].nil?
        
        query.issue.delete(:namespace)  
    
    end

    unless query.order[:builder].nil?
        
        query.order.delete(:builder)  
    
    end

    unless query.order[:namespace].nil?
        
        query.order.delete(:namespace)  
    
    end

    query
  end

  def to_filter_params
    params = {}
    params[:project_id] = project_id if project_id
    @@available_filters.keys.each do |filter_group|
      params[filter_group] = self[filter_group] unless self[filter_group].blank?
    end
    params
  end

  def editable?(incl_editable_attr = true)
    editable_by? User.current, incl_editable_attr
  end

  def editable_by?(user, incl_editable_attr = true)
    result = new_record? || user.admin? || user == created_by
    return result || editable if incl_editable_attr
    result
  end

  # Override attributes to track whether a filter has been applied
  def source=(value)
    if value.is_a? Symbol or value.is_a? String
      set_filter_attr(:source, { :ids_mode => value.to_s })
    else
      set_filter_attr(:source, value)
    end
  end

  def sink=(value)
    if value.is_a? Symbol or value.is_a? String
      set_filter_attr(:sink, { :ids_mode => value.to_s })
    else
      set_filter_attr(:sink, value)
    end
  end

  def issue=(value)
    if value.is_a? Symbol or value.is_a? String
      set_filter_attr(:issue, { :ids_mode => value.to_s })
    else
      set_filter_attr(:issue, value)
    end
  end

  def order
    return self[:order] unless self[:order].blank?
    @@default_order
  end

  def order=(value)
    # self[:order] = value unless value.blank?
    set_filter_attr(:order, value)
  end

  # Builds the SQL string that can be passed as order statement in a ReArtifactProperties finder method
  def order_string
    column = order[:column]
    column = @@default_order[:column] unless column
    direction = order[:direction]
    direction = @@default_order[:direction] unless direction
    "#{column} #{direction.upcase}"
  end

  def set_by_params?
    @set_by_params
  end

  # Builds the SQL string that can be passed as condition in a ReArtifactProperties finder method
  def conditions
    
    conditions = []
    # Basic conditions
    conditions << ["#{ReArtifactProperties.table_name}.artifact_type != ?", 'Project']
    conditions << ["#{ReArtifactProperties.table_name}.project_id = ?", project_id] if project_id
    # Custom filter conditions
    conditions.concat(@@available_filters.values.flatten.compact.map { |filter| filter.new(self).conditions })
    # Merge all sanitizable condition arrays
    merge_conditions(conditions)
  end

  private
  def assign_creator
    self.created_by = self.updated_by = User.current
  end

  def assign_maintainer
    self.updated_by = User.current
  end

  # If no roles are selected make the query exclusively visible to the current user
  def repair_visibility
    if visibility == VISIBILITY[:roles] and visible_role_ids.blank?
      self.visibility = VISIBILITY[:me]
    end
  end

  def clear_unassigned_visible_roles
    if visibility != VISIBILITY[:roles]
      self.visible_roles.delete_all
    end
  end

  # Marks the query as set
  def set_filter_attr(attr, value)
    value ||= {}
    self[attr] = value
    unless @set_by_params
      @set_by_params = true unless value.blank?
    end
  end

  # Creates the user visibility SQL condition for named scopes 'visible' and 'visible_for'
  def self.visibility_condition(user)
    unless user.admin?
      inner_sql = %{SELECT inner.*
                    FROM #{ReQuery.table_name} AS inner
                    INNER JOIN re_queries_roles ON re_queries_roles.query_id = inner.id
                    INNER JOIN #{MemberRole.table_name} ON #{MemberRole.table_name}.role_id = re_queries_roles.role_id
                    INNER JOIN #{Member.table_name} ON #{Member.table_name}.id = #{MemberRole.table_name}.member_id
                    WHERE #{Member.table_name}.user_id = ?}
      sql = %{(#{ReQuery.table_name}.visibility = ?) OR
              (#{ReQuery.table_name}.visibility = ? AND (#{ReQuery.table_name}.created_by = ? OR
                                                         #{ReQuery.table_name}.updated_by = ?)) OR
              (#{ReQuery.table_name}.visibility = ? AND EXISTS(#{inner_sql}))}
      { :conditions => [sql, VISIBILITY[:public], VISIBILITY[:me], user.id, user.id, VISIBILITY[:roles], user.id] }
    end
  end

  # Merges multiple SQL condition Arrays into a single one that eventually will be sanitized Rails-internally
  def merge_conditions(conditions, with = 'AND')
    conditions = conditions.reject { |c| c.blank? }
    sql = conditions.map { |condition| "(#{condition.first})" }.join(" #{with} ")
    result = [sql]
    conditions.each do |condition|
      result.concat(condition[1..-1])
    end
    result
  end
end