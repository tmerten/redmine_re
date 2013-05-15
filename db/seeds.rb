Project.create("description"=>"", "homepage"=>"", "identifier"=>"test", "is_public"=>true, "name"=>"Testproject", "parent_id"=>nil)
Project.create("description"=>"", "homepage"=>"", "identifier"=>"test", "is_public"=>true, "name"=>"Testproject", "parent_id"=>nil)
Setting.create("name"=>"login_required", "value"=>"0")
Setting.create("name"=>"autologin", "value"=>"0")
Setting.create("name"=>"self_registration", "value"=>"2")
Setting.create("name"=>"unsubscribe", "value"=>"1")
Setting.create("name"=>"password_min_length", "value"=>"4")
Setting.create("name"=>"lost_password", "value"=>"1")
Setting.create("name"=>"openid", "value"=>"0")
Setting.create("name"=>"rest_api_enabled", "value"=>"0")
Setting.create("name"=>"session_lifetime", "value"=>"0")
Setting.create("name"=>"session_timeout", "value"=>"0")
# Make sure that the setting password_min_length is not to high (by default it is 8 and the admin:admin combo dose not work!)
User.create("admin"=>true, "auth_source_id"=>nil, "firstname"=>"Redmine", "hashed_password"=>"1e56cb70d72db24a0de527ef6c18c7d6045d1b47", "identity_url"=>nil, "language"=>"en", "lastname"=>"Admin", "login"=>"admin", "mail"=>"admin@example.net", "mail_notification"=>"all", "salt"=>"634291fb11a47e354ae2a50be8e50b4e", "status"=>1)
# Make sure that the setting password_min_length is not to high (by default it is 8 and the admin:admin combo dose not work!)
User.create("admin"=>false, "auth_source_id"=>nil, "firstname"=>"", "hashed_password"=>"", "identity_url"=>nil, "language"=>"", "lastname"=>"Anonymous", "login"=>"", "mail"=>nil, "mail_notification"=>"only_my_events", "salt"=>nil, "status"=>0)
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
Role.create("assignable"=>true, "builtin"=>1, "issues_visibility"=>"default", "name"=>"Non member", "permissions"=>[:view_issues, :add_issues, :add_issue_notes, :save_queries, :view_gantt, :view_calendar, :view_time_entries, :comment_news, :view_documents, :view_wiki_pages, :view_wiki_edits, :add_messages, :view_files, :browse_repository, :view_changesets], "position"=>1)
Role.create("assignable"=>true, "builtin"=>2, "issues_visibility"=>"default", "name"=>"Anonymous", "permissions"=>[:view_issues, :view_gantt, :view_calendar, :view_time_entries, :view_documents, :view_wiki_pages, :view_wiki_edits, :view_files, :browse_repository, :view_changesets], "position"=>2)
Role.create("assignable"=>true, "builtin"=>0, "issues_visibility"=>"all", "name"=>"Manager", "permissions"=>[:add_project, :edit_project, :close_project, :select_project_modules, :manage_members, :manage_versions, :add_subprojects, :manage_categories, :view_issues, :add_issues, :edit_issues, :manage_issue_relations, :manage_subtasks, :set_issues_private, :set_own_issues_private, :add_issue_notes, :edit_issue_notes, :edit_own_issue_notes, :view_private_notes, :set_notes_private, :move_issues, :delete_issues, :manage_public_queries, :save_queries, :view_issue_watchers, :add_issue_watchers, :delete_issue_watchers, :log_time, :view_time_entries, :edit_time_entries, :edit_own_time_entries, :manage_project_activities, :manage_news, :comment_news, :manage_documents, :view_documents, :manage_files, :view_files, :manage_wiki, :rename_wiki_pages, :delete_wiki_pages, :view_wiki_pages, :export_wiki_pages, :view_wiki_edits, :edit_wiki_pages, :delete_wiki_pages_attachments, :protect_wiki_pages, :manage_repository, :browse_repository, :view_changesets, :commit_access, :manage_related_issues, :manage_boards, :add_messages, :edit_messages, :edit_own_messages, :delete_messages, :delete_own_messages, :view_calendar, :view_gantt, :view_requirements, :edit_requirements, :administrate_requirements, :comment_on_requirements, :delete_re_artifact_properties_watchers], "position"=>3)
Role.create("assignable"=>true, "builtin"=>0, "issues_visibility"=>"default", "name"=>"Developer", "permissions"=>[:manage_versions, :manage_categories, :view_issues, :add_issues, :edit_issues, :view_private_notes, :set_notes_private, :manage_issue_relations, :manage_subtasks, :add_issue_notes, :save_queries, :view_gantt, :view_calendar, :log_time, :view_time_entries, :comment_news, :view_documents, :view_wiki_pages, :view_wiki_edits, :edit_wiki_pages, :delete_wiki_pages, :add_messages, :edit_own_messages, :view_files, :manage_files, :browse_repository, :view_changesets, :commit_access, :manage_related_issues], "position"=>4)
Role.create("assignable"=>true, "builtin"=>0, "issues_visibility"=>"default", "name"=>"Reporter", "permissions"=>[:view_issues, :add_issues, :add_issue_notes, :save_queries, :view_gantt, :view_calendar, :log_time, :view_time_entries, :comment_news, :view_documents, :view_wiki_pages, :view_wiki_edits, :add_messages, :edit_own_messages, :view_files, :browse_repository, :view_changesets], "position"=>5)
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
