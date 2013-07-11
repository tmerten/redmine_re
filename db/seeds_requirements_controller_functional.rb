Project.create("description"=>"", "homepage"=>"", "identifier"=>"test", "is_public"=>true, "name"=>"Testproject", "parent_id"=>nil)
EnabledModule.create("name"=>"issue_tracking", "project_id"=>1)
EnabledModule.create("name"=>"time_tracking", "project_id"=>1)
EnabledModule.create("name"=>"news", "project_id"=>1)
EnabledModule.create("name"=>"documents", "project_id"=>1)
EnabledModule.create("name"=>"files", "project_id"=>1)
EnabledModule.create("name"=>"wiki", "project_id"=>1)
EnabledModule.create("name"=>"repository", "project_id"=>1)
EnabledModule.create("name"=>"boards", "project_id"=>1)
EnabledModule.create("name"=>"calendar", "project_id"=>1)
EnabledModule.create("name"=>"gantt", "project_id"=>1)
EnabledModule.create("name"=>"requirements", "project_id"=>1)
ReArtifactProperties.create("artifact_id"=>1, "artifact_type"=>"Project", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Testproject", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1)
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReSection", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Chapter 1", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(1),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(2))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReSection", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Chapter 2", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(1),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(3))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReRequirement", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Requirement 1.1", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(2),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(4))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReRequirement", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Requirement 1.2", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(2),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(5))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReRequirement", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Requirement 1.3", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(2),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(6))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReGoal", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Goal 2.1", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(3),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(7))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReGoal", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Goal 2.2", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(3),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(8))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReSection", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Chapter 3", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(1),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(9))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReUserProfile", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Userprofil 3.1", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(9),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(10))
ReArtifactProperties.create("artifact_id"=>nil, "artifact_type"=>"ReUserProfile", "comments_count"=>nil, "created_by"=>1, "description"=>"", "name"=>"Userprofil 3.2", "project_id"=>1, "responsible_id"=>nil, "updated_by"=>1,
"parent" => ReArtifactProperties.find(9),
"parent_relation" => ReArtifactRelationship.find_by_sink_id(11))
ReSetting.create("name"=>"artifact_order", "project_id"=>1, "value"=>"[\"re_vision\",\"re_workarea\",\"re_processword\",\"re_rationale\",\"re_requirement\",\"re_scenario\",\"re_task\",\"re_goal\",\"re_attachment\",\"re_section\",\"re_use_case\",\"re_user_profile\"]")
ReSetting.create("name"=>"re_vision", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Vision\",\"color\":\"#00ff00\",\"printable\":false}")
ReSetting.create("name"=>"re_workarea", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Workarea\",\"color\":\"#993300\",\"printable\":false}")
ReSetting.create("name"=>"re_processword", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Processword\",\"color\":\"#808000\",\"printable\":false}")
ReSetting.create("name"=>"re_rationale", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Rationale\",\"color\":\"#FFA733\",\"printable\":false}")
ReSetting.create("name"=>"re_requirement", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Requirement\",\"color\":\"#ffcc00\",\"printable\":false}")
ReSetting.create("name"=>"re_scenario", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Scenario\",\"color\":\"#00ccff\",\"printable\":false}")
ReSetting.create("name"=>"re_task", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Task\",\"color\":\"#ff0000\",\"printable\":false}")
ReSetting.create("name"=>"re_goal", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Goal\",\"color\":\"#339966\",\"printable\":false}")
ReSetting.create("name"=>"re_attachment", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Attachment\",\"color\":\"#000000\",\"printable\":false}")
ReSetting.create("name"=>"re_section", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Section\",\"color\":\"#c0c0c0\",\"printable\":false}")
ReSetting.create("name"=>"re_use_case", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Use case\",\"color\":\"#0000ff\",\"printable\":false}")
ReSetting.create("name"=>"re_user_profile", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"User profile\",\"color\":\"#ff99cc\",\"printable\":false}")
ReSetting.create("name"=>"dependency", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Dependency\",\"color\":\"#00ff00\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"conflict", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Conflict\",\"color\":\"#ff0000\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"rationale", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Rationale\",\"color\":\"#993300\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"refinement", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Refinement\",\"color\":\"#33cccc\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"part_of", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Part of\",\"color\":\"#ffcc00\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"parentchild", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Parentchild\",\"color\":\"#0000ff\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"primary_actor", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Primary actor\",\"color\":\"#999900\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"actors", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Actors\",\"color\":\"#339966\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"diagram", "project_id"=>1, "value"=>"{\"in_use\":true,\"alias\":\"Diagram\",\"color\":\"#A127F2\",\"show_in_visualization\":true}")
ReSetting.create("name"=>"relation_management_pane", "project_id"=>1, "value"=>"false")
ReSetting.create("name"=>"visualization_size", "project_id"=>1, "value"=>"800")
ReSetting.create("name"=>"plugin_description", "project_id"=>1, "value"=>"")
ReSetting.create("name"=>"relation_order", "project_id"=>1, "value"=>"[\"dependency\",\"conflict\",\"rationale\",\"refinement\",\"part_of\",\"parentchild\",\"primary_actor\",\"actors\",\"diagram\"]")
ReSetting.create("name"=>"unconfirmed", "project_id"=>1, "value"=>"false")
ReSetting.create("name"=>"export_format", "project_id"=>1, "value"=>"disabled")
ReArtifactRelationship.create("position"=>1, "relation_type"=>"parentchild", "sink_id"=>2, "source_id"=>1)
ReArtifactRelationship.create("position"=>2, "relation_type"=>"parentchild", "sink_id"=>3, "source_id"=>1)
ReArtifactRelationship.create("position"=>1, "relation_type"=>"parentchild", "sink_id"=>4, "source_id"=>2)
ReArtifactRelationship.create("position"=>3, "relation_type"=>"parentchild", "sink_id"=>5, "source_id"=>2)
ReArtifactRelationship.create("position"=>4, "relation_type"=>"parentchild", "sink_id"=>6, "source_id"=>2)
ReArtifactRelationship.create("position"=>1, "relation_type"=>"parentchild", "sink_id"=>7, "source_id"=>3)
ReArtifactRelationship.create("position"=>2, "relation_type"=>"parentchild", "sink_id"=>8, "source_id"=>3)
ReArtifactRelationship.create("position"=>3, "relation_type"=>"parentchild", "sink_id"=>9, "source_id"=>1)
ReArtifactRelationship.create("position"=>1, "relation_type"=>"parentchild", "sink_id"=>10, "source_id"=>9)
ReArtifactRelationship.create("position"=>2, "relation_type"=>"parentchild", "sink_id"=>11, "source_id"=>9)
