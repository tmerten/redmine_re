RedmineApp::Application.routes.draw do
  match 'projects/:project_id/requirements' => 'requirements#index', :via => :get
  #match 'projects/:project_id/requirements/settings/firstload' => 're_settings#configure', :firstload => '1'
  #match 'projects/:project_id/requirements/settings' => 're_settings#configure'
  #match 'projects/:project_id/requirements/settings/:artifact_type/description/edit' => 're_settings#edit_artifact_type_description'
  #match 'projects/:project_id/requirements/settings/:artifact_type/fields/edit' => 're_settings#configure_fields'
  #match 'projects/:project_id/requirements/treefilter' => 'requirements#treefilter'
  #match 'projects/:project_id/requirements/relations/visualization' => 're_artifact_relationship#visualization'
  #match 'projects/:project_id/requirements/relations/visualization/show' => 're_artifact_relationship#build_json_according_to_user_choice'
  #match 'projects/:project_id/requirements/tree/treestate' => 'requirements#treestate'
  #match 'projects/:project_id/requirements/tree/treestate/:id' => 'requirements#treestate'
  #match 'projects/requirements/tree/drop' => 'requirements#delegate_tree_drop'
  #match 'projects/:project_id/relation/prepare/:id' => 're_artifact_relationship#prepare_relationships'
  #match 'projects/:project_id/relation/autocomplete/sink/:id' => 're_artifact_relationship#autocomplete_sink'
  #match 'projects/:project_id/requirements/artifact/autocomplete/issue' => 're_artifact_properties#autocomplete_issue'
  #match 'projects/:project_id/issues/new/connected_to/:artifacttype/:associationid' => 'issues#new'
  #match 'projects/:project_id/requirements/artifact/autocomplete/artifact' => 're_artifact_properties#autocomplete_artifact'
  #resources :re_artifact_properties, :except => [:show, :new, :index]
  #match 'artifact/:id/rate/:stars' => 're_artifact_properties#rate_artifact'
  #match 'projects/:project_id/requirements/artifact/new/:artifact_type' => 're_artifact_properties#new'
  #match 'projects/:project_id/requirements/artifact/new/:artifact_type/inside_of/:parent_artifact_id' => 're_artifact_properties#new'
  #match 'projects/:project_id/requirements/artifact/new/:artifact_type/below_of/:sibling_artifact_id' => 're_artifact_properties#new'
  #resources :re_queries do
  #  collection do
  #post :apply
  #get :suggest_artifacts
  #get :suggest_issues
  #get :suggest_users
  #get :artifacts_bits
  #get :issues_bits
  #get :users_bits
  #end
  #  member do
  #get :delete
  #end
  #
  #end
end
