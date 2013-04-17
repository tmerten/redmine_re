module ReArtifactPropertiesHelper
  #include ApplicationHelper

  def artifact_heading(artifact)
    h("#{rendered_artifact_type(artifact.artifact_type)} ##{artifact.id} ")
  end

  def autocomplete_issue
    query = '%' + params[:issue_subject].gsub('%', '\%').gsub('_', '\_').downcase + '%'
    issues_for_ac = Issue.find(:all, :conditions => ['subject like ? AND project_id=?', query, @project.id])
    list = '<ul>'
    issues_for_ac.each do |issue|
      list << '<li ' + 'id='+issue.id.to_s+'>'
      list << issue.subject.to_s+' ('+issue.id.to_s+')'
      list << '</li>'
    end

    list << '</ul>'
    render :text => list
  end

  def format_expansions_field_name (field_html, use_case_step_id)
    begin
      field_html["re_artifact_properties[artifact_attributes][re_use_case_steps_attributes][re_use_case_step_expansions_attributes]"] = "re_artifact_properties[artifact_attributes][re_use_case_steps_attributes][][re_use_case_step_expansions_attributes]["+use_case_step_id.to_s+"]"
      field_html["["+use_case_step_id.to_s+"][]"] = "["+use_case_step_id.to_s+"]"
    rescue
      logger.debug("The re Use Case Expansion name replace method (re_application_helper) somtimes fails !!!!!!!!!!!!")
      logger.debug(field_html)
    end

    field_html
  end

  def rate
    if @rating = User.current.ratings.find_by_re_artifact_properties_id(params[:id])
      @rating
    else
      @re_artifact_properties.ratings.new
    end
  end
end
