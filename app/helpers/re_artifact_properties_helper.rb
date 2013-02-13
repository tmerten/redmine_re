module ReArtifactPropertiesHelper
  #include ApplicationHelper

  def artifact_heading(artifact)
    h("#{rendered_artifact_type(artifact.artifact_type)} ##{artifact.id} ")
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
  
end
