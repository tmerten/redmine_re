ActionController::Routing::Routes.draw do |map|
  map.resources :requirements, :path_prefix => '/projects/:project_id'
  map.resources :re_goal, :path_prefix => '/projects/:project_id'
  map.resources :re_section, :path_prefix => '/projects/:project_id'
  map.resources :re_subtask, :path_prefix => '/projects/:project_id'
  map.resources :re_task , :path_prefix => '/projects/:project_id'
  map.resources :re_user_profile, :path_prefix => '/projects/:project_id'
  map.resources :re_attachment, :path_prefix => '/projects/:project_id'
  map.resources :re_vision, :path_prefix => '/projects/:project_id'
  map.resources :re_workarea, :path_prefix => '/projects/:project_id'
  map.resources :re_artifact_relationship, :path_prefix => '/projects/:project_id'
end