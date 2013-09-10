module ReApplicationHelper
  def rendered_relation_type(relation_type)
    relation_type_alias = @re_relation_settings[relation_type]['alias']
    relation_type_humanized = relation_type.humanize

    if relation_type_alias.blank? or relation_type_humanized.eql?(relation_type_alias)
      return t('re_' + relation_type)
    else
      return relation_type_alias
    end
  end

  # shows the default or configured name for an artifact type
  # e.g. rendered_artifact_type('artifact_type')
  # or   rendered_artifact_type(my_artifact_instance.artifact_type)
  def rendered_artifact_type(artifact_type)
    artifact_type_alias = ''
    re_artifact_settings = ReSetting.active_re_artifact_settings(@project.id)
    unless re_artifact_settings[artifact_type].nil?
      artifact_type_alias = re_artifact_settings[artifact_type]['alias']
    end
    humanized_artifact_type = artifact_type.gsub(/^re_/, '').humanize

    if artifact_type_alias.blank? or humanized_artifact_type.eql?(artifact_type_alias)
      return t(artifact_type)
    else
      return artifact_type_alias
    end
  end

  def current_user
    User.current
  end

  # Error messages have to be created for the artifact
  # or builiding block that is named in the variable artifact 
  def errors_and_flash(artifact)
    s = error_messages_for artifact
    flash.each do |k, v|
      s << content_tag('div', v, :class => "flash #{k}")
    end
    s.html_safe
  end

  # creates a link to the wikipage of an artifact => wiki/#id_#artifact_type_#name/
  # if there is already a wikipage the content will be placed as a tooltip to the link
  def wiki_page_of_re_artifact(project, re_artifact) #todo subtasks wiki link..
    return t(:re_wiki_page_available_after_save) if re_artifact.id.blank? # only when already saved artifact

    # check instance
    re_artifact = (re_artifact.instance_of?(ReArtifactProperties)) ? re_artifact : re_artifact.re_artifact_properties

    # check if a wiki page already exist for this artifact
    html_code = ""
    wiki_page_name = "#{re_artifact.id}_#{re_artifact.artifact_type}"
    wiki_page = WikiPage.find_by_title(wiki_page_name)
    has_no_wiki_page_yet = (wiki_page.nil?) ? true : false

    # variable icon

    if has_no_wiki_page_yet
      html_code += link_to t(:re_create_wiki_page_for_re_artifact), {
          :controller => 'wiki',
          :action => 'edit',
          :id => wiki_page_name,
          :project_id => project.identifier},
                           {:class => "icon icon-subtask-wiki-new"}
    else
      html_code += link_to t(:re_show_wiki_page_for_re_artifact), {
          :controller => 'wiki',
          :action => 'show',
          :id => wiki_page_name,
          :project_id => project.identifier}

      html_code += " ("

      html_code += link_to t(:re_edit), {
          :controller => 'wiki',
          :action => 'edit',
          :id => wiki_page_name,
          :project_id => project.identifier},
                           {:class => "icon icon-subtask-wiki-edit"}

      html_code += ")"
    end
    return html_code
  end

  def redmine_version_is_higher_or_equal_than?(compare_version_str)
    # helper which checks if the current redmine version is higher or equal than another

    # complete version string example: 1.1.2.stable
    current_version_str = Redmine::VERSION.to_s

    # get the version numbers 1.2.1.stable => [1, 2, 1]
    get_version_numbers = Regexp.new(/\A(\d+)\.(\d+)\.(\d+)/)

    m = compare_version_str.match(get_version_numbers)
    raise ArgumentError, "The version string: #{compare_version_str} contains not a valid version!" if m.nil?
    compare_version_numbers = [$1.to_i, $2.to_i, $3.to_i]

    current_version_str.match(get_version_numbers)
    current_version_numbers = [$1.to_i, $2.to_i, $3.to_i]

    # compare the version numbers 
    result = true
    current_version_numbers.each_index do |i|
      if (current_version_numbers[i] < compare_version_numbers[i])
        result = false
      end
    end
    return result
  end

  def edit_re_artifact_properties_path(artifact)
    url_for :controller => artifact.artifact_type.underscore,
            :action => 'edit',
            :id => artifact.artifact_id
  end

  PLUGIN_NAME = File.expand_path('../../*', __FILE__).match(/.*\/(.*)\/\*$/)[1].to_sym

  def plugin_asset_link(asset_name, options={})
    plugin_name=(options[:plugin] ? options[:plugin] : PLUGIN_NAME)
    File.join(Redmine::Utils.relative_url_root, 'plugin_assets', plugin_name.to_s, asset_name)
  end

  # renders a link to javascript to remove fields for nested object forms
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => "icon icon-del")
  end

  # renders a link to javascrip to add an empty object into a nested forms 
  def link_to_add_fields(name, f, association, templatedir = "")
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for("#{association}_attributes", new_object, :index => "new_#{association}") do |builder|

      logger.debug "********************************************** #{association.to_s.singularize}"
      if templatedir.blank?
        render(association.to_s.singularize + "_fields", :f => builder)
      else
        render("#{templatedir}/#{association.to_s.singularize}_fields", :f => builder)
      end
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  # renders a link to javascrip to add an empty object into a nested forms 
  def get_escaped_setp_html(f, step_type)
    new_object = ReUseCaseStep.new()
    new_object = f.object.class.reflect_on_association(:re_use_case_steps).klass.new(:step_type => step_type)
    fields = f.fields_for("re_use_case_steps_attributes", new_object, :index => "new_re_use_case_step") do |builder|
      render("re_use_case/re_use_case_step_fields", :f => builder)
    end
    escape_javascript(fields)
  end

  # renders a link to javascrip to add an empty object into a nested forms 
  def get_escaped_subtask_html(f, sub_type)
    new_object = ReSubtask.new()
    new_object = f.object.class.reflect_on_association(:re_subtasks).klass.new(:sub_type => sub_type)
    fields = f.fields_for("re_subtasks_attributes", new_object, :index => "new_re_subtask") do |builder|
      render("re_task/subtasks", :f => builder)
    end
    escape_javascript(fields)
  end
end
