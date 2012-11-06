RedmineApp::Application.routes.draw do
  match 'projects/:project_id/requirements' => 'requirements#index', :via => :get
  match 'projects/:project_id/requirements/settings/firstload' => 're_settings#configure', :firstload => '1'
  match 'projects/:project_id/requirements/settings' => 're_settings#configure'
  match 'projects/:project_id/requirements/settings/:artifact_type/description/edit' => 're_settings#edit_artifact_type_description'
  match 'projects/:project_id/requirements/settings/:artifact_type/fields/edit' => 're_settings#configure_fields'
  match 'projects/:project_id/requirements/treefilter' => 'requirements#treefilter'
  match 'projects/:project_id/requirements/relations/visualization' => 're_artifact_relationship#visualization'
  match 'projects/:project_id/requirements/relations/visualization/show/:visualization_type' => 're_artifact_relationship#build_json_according_to_user_choice'
  match 'projects/:project_id/requirements/tree/treestate' => 'requirements#treestate'
  match 'projects/:project_id/requirements/tree/treestate/:id' => 'requirements#treestate'
  match 'projects/:project_id/requirements/tree/treestate/:current_actifact_id/:id' => 'requirements#treestate'
  match 'projects/requirements/tree/drop' => 'requirements#delegate_tree_drop'
  match 'projects/:project_id/relation/prepare/:id' => 're_artifact_relationship#prepare_relationships'
  match 'projects/:project_id/relation/autocomplete/sink/:id' => 're_artifact_relationship#autocomplete_sink'
  match 'projects/:project_id/requirements/artifact/autocomplete/issue' => 're_artifact_properties#autocomplete_issue'
  match 'projects/:project_id/issues/new/connected_to/:artifacttype/:associationid' => 'issues#new'
  match 'projects/:project_id/requirements/artifact/autocomplete/artifact' => 're_artifact_properties#autocomplete_artifact'
  resources :re_artifact_properties, :except => [:show, :new, :index]
  match 'artifact/:id/rate/:stars' => 're_artifact_properties#rate_artifact'
  match 'projects/:project_id/requirements/artifact/new/:artifact_type' => 're_artifact_properties#new'
  match 'projects/:project_id/requirements/artifact/new/:artifact_type/inside_of/:parent_artifact_id', :to => 're_artifact_properties#new', :as => 're_artifact_properti'
  match 'projects/:project_id/requirements/artifact/new/:artifact_type/below_of/:sibling_artifact_id' => 're_artifact_properties#new'
  match 'projects/:project_id/requirements/autcomplete' => 're_artifact_properties#autocomplete_artifact'
  match 'projects/:project_id/requirements/filtered_json' => 're_artifact_relationship#build_json_according_to_user_choice'
  
  match 're_artifact_properties/:id/edit' => 're_artifact_properties#edit'
  match 're_artifact_properties/:id/delete' => 're_artifact_properties#delete'
  match 're_artifact_properties/:id/recursive_delete' => 're_artifact_properties#recursive_delete'
  match 're_artifact_properties/:id/how_to_delete' => 're_artifact_properties#how_to_delete'
  
  
  match 'projects/:project_id/ralation/prepare/:id' => 're_artifact_relationship_controller#prepare_relationships'
  match 'projects/:project_id/ralation/autocomplete/sink/:id' => 're_artifact_relationship_controller#autocomplete_sink'
  
  match ':project_id/:id/:re_artifact_properties_id/delete' => 're_artifact_relationship#delete'
  match 're_queries.:project_id' => 'redmine_re#enhanced_filter'
  match '/re_queries/suggest_artifacts.:id' => 're_queries#suggest_artifacts'

  match '' => 're_use_case#autocomplete_sink'
  
  resources :re_queries do
    collection do
      post :apply
      get :suggest_artifacts
      get :suggest_issues
      get :suggest_users
      get :artifacts_bits
      get :issues_bits
      get :users_bits
    end
  end
  #member do
  #  get :delete
  #  end
  #end
end
