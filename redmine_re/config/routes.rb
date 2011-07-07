# http://guides.rubyonrails.org/v2.3.8/routing.html#route-options to simplify routes

ActionController::Routing::Routes.draw do |map|
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

  #these arent empty rules. they are needed to skip the path_prefix during editing requirements
  map.resources :re_goal
  map.resources :requirements
  map.resources :re_section
  map.resources :re_subtask
  map.resources :re_task
  map.resources :re_user_profile
  map.resources :re_attachment
  map.resources :re_vision
  map.resources :re_workarea
  map.resources :re_artifact_relationship
  map.resources :re_scenario
  map.resources :re_requirement

end