module ReQueriesHelper
  def re_query_form_url(query, mode)
    if mode == :persist
      (query.new_record? ? re_queries_path : re_query_path(query.project_id, query))
    else
      { :action => 'apply' }
    end
  end

  def artifact_controller(artifact)
    artifact.artifact_type.underscore
  end

  def query_visibility_modes
    [[l(:re_query_visibility_public), ReQuery::VISIBILITY[:public]],
     [l(:re_query_visibility_me), ReQuery::VISIBILITY[:me]],
     [l(:re_query_visibility_roles), ReQuery::VISIBILITY[:roles]]]
  end

  def source_artifact_modes
    %w(some contains not_contains)
  end

  def sink_artifact_modes
    source_artifact_modes.dup.insert(0, 'any').insert(2, 'none')
  end

  def artifact_modes(attribute)
    if attribute == :sink
      sink_artifact_modes
    else
      source_artifact_modes
    end
  end

  def artifact_name_modes
    %w(any equals not_equals contains not_contains)
  end

  def artifact_type_modes
    %w(any contains not_contains)
  end

  def relation_type_modes
    artifact_type_modes
  end

  def issue_modes
    sink_artifact_modes
  end

  def creator_modes
    name_modes.dup.insert(1, 'is_me').insert(2, 'is_not_me')
  end

  def maintainer_modes
    creator_modes
  end

  def role_modes
    name_modes
  end

  def creator_role_modes
    role_modes
  end

  def maintainer_role_modes
    role_modes
  end

  def author_modes
    creator_modes
  end

  def author_role_modes
    role_modes
  end

  def assignee_modes
    author_modes.insert(1, 'none').insert(2, 'some')
  end

  def assignee_role_modes
    author_role_modes
  end

  def order_directions
    %w(asc desc)
  end

  # Creates a select box containing the different filter modes
  def matching_modes_for_select(matching_modes)
    matching_modes.collect { |mode| [l(:"label_#{mode}"), mode] }
  end

  # Basic operators
  def name_modes
    %w(any contains not_contains)
  end
end
