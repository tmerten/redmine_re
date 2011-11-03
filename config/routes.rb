ActionController::Routing::Routes.draw do |map|
  #map.project "/project/edit/:id", :controller => 'requirements', :action => 'index'
  map.resources :requirements, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_goal  , :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_section, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_subtask, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_task , :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_user_profile, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_attachment, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_vision, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_workarea, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_artifact_relationship, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_scenario, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_requirement, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_processword, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_settings, :path_prefix => '/projects/:project_id', :except => :edit
  map.resources :re_rationale, :path_prefix => '/projects/:project_id', :except => :edit
end
