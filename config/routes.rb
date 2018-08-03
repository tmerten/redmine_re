RedmineApp::Application.routes.draw do
  resources :re_ratings

  match 'projects/:project_id/requirements' => 'requirements#index', :via => [:get, :post]
  match 'projects/:project_id/requirements/settings/firstload' => 're_settings#configure', :firstload => '1', :via => [:get, :post]
  match 'projects/:project_id/requirements/settings' => 're_settings#configure', :via => [:get, :post]
  match 'projects/:project_id/requirements/settings/:artifact_type/description/edit' => 're_settings#edit_artifact_type_description', :via => [:get, :post]
  match 'projects/:project_id/requirements/settings/:artifact_type/fields/edit' => 're_settings#configure_fields', :via => [:get, :post]
  match 'projects/:project_id/requirements/treefilter' => 'requirements#treefilter', :via => [:get, :post]
  match 'projects/:project_id/requirements/relations/visualization/' => 're_artifact_relationship#visualization', :via => [:get, :post]
  match 'projects/:project_id/requirements/relations/visualization/show/:visualization_type' => 're_artifact_relationship#build_json_according_to_user_choice', :via => [:get, :post]
  match 'projects/:project_id/requirements/relations/visualization_get/:artifact_id/:visualization_type' => 're_artifact_relationship#visualization', :via => [:get, :post]
  match 'projects/:project_id/requirements/tree/:mode' => 'requirements#tree', :via => [:get, :post]
  match 'projects/:project_id/requirements/tree/:mode/:id' => 'requirements#tree', :via => [:get, :post]

  match 'projects/requirements/tree/drop' => 'requirements#delegate_tree_drop', :via => [:get, :post]
  match 'projects/:project_id/use_case/autocomplete/sink' => 're_use_case#autocomplete_sink', :via => [:get, :post]
  match 'projects/:project_id/issues/new/connected_to/:artifacttype/:associationid' => 'issues#new', :via => [:get, :post]
  match 'projects/:project_id/requirements/filtered_json' => 're_artifact_relationship#build_json_according_to_user_choice', :via => [:get, :post]

  # ReArtifactProperties as "artifact"
  resources :re_artifact_properties, :except => [:new, :index], :via => [:get, :post]

  match 're_artifact_properties/:id/recursive_destroy' => 're_artifact_properties#recursive_destroy', :via => [:get, :post]
  match 're_artifact_properties/:id/how_to_delete' => 're_artifact_properties#how_to_delete', :via => [:get, :post]
  match 'projects/:project_id/requirements/remove/:artifactid/from_issue/:issueid' => 're_artifact_properties#remove_artifact_from_issue', :via => [:get, :post]
  match 'projects/:project_id/requirements/artifact/new/:artifact_type' => 're_artifact_properties#new', :via => [:get, :post]
  match 'projects/:project_id/requirements/artifact/new/:artifact_type/inside_of/:parent_artifact_id', :to => 're_artifact_properties#new', :as => 're_artifact_properti', :via => [:get, :post]
  match 'projects/:project_id/requirements/artifact/new/:artifact_type/below_of/:sibling_artifact_id' => 're_artifact_properties#new', :via => [:get, :post]

  match 'projects/:project_id/requirements/autcomplete' => 're_artifact_properties#autocomplete_artifact', :via => [:get, :post]
  match 'projects/:project_id/requirements/artifact/autocomplete/issue' => 're_artifact_properties#autocomplete_issue', :via => [:get, :post]
  match 'projects/:project_id/requirements/artifact/autocomplete/artifact' => 're_artifact_properties#autocomplete_artifact', :via => [:get, :post]

  match 'projects/:project_id/requirements/artifact/new_comment/:id' => 're_artifact_properties#new_comment', :via => [:get, :post]

  match ':project_id/:id/:re_artifact_properties_id/delete' => 're_artifact_relationship#delete', :via => [:get, :post]
  match 'projects/:project_id/ralation/prepare/:id' => 're_artifact_relationship_controller#prepare_relationships', :via => [:get, :post]
  match 'projects/:project_id/ralation/autocomplete/sink/:id' => 're_artifact_relationship_controller#autocomplete_sink', :via => [:get, :post]
  match '/relation/add' => 'requirements#add_relation', :via => [:get, :post]

  match 'projects/:project_id/re_queries' => 're_queries#index', :via => [:get, :post]
  match 'projects/:project_id/re_queries/:id/delete' => 're_queries#delete', :via => [:get, :post]

  scope "(/projects/:project_id)" do
    resources :re_queries do
      collection do
        post :apply
        get :suggest_artifacts
        get :suggest_issues
        get :suggest_diagrams
        get :suggest_users
        get :artifacts_bits
        get :issues_bits
        get :diagrams_bits
        get :users_bits
      end
    end

  end

  match "projects/:project_id/diagram_preview/:diagram_id" => 'requirements#sendDiagramPreviewImage', :via => [:get, :post]
end
