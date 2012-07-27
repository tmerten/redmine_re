
ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/requirements', :controller => :requirements, :action => :index, :conditions => {:method => :get} 

  map.connect 'projects/:project_id/requirements/settings/firstload', :controller=>"re_settings", :action=>"configure", :firstload=>"1"
  map.connect 'projects/:project_id/requirements/settings', :controller=>"re_settings", :action=>"configure"

  map.connect 'projects/:project_id/requirements/settings/:artifact_type/description/edit', :controller=>"re_settings", :action=>"edit_artifact_type_description"
  map.connect 'projects/:project_id/requirements/settings/:artifact_type/fields/edit', :controller=>"re_settings", :action=>"configure_fields"

  map.connect 'projects/:project_id/requirements/treefilter', :controller=>"requirements", :action=>"treefilter"

  map.connect 'projects/:project_id/requirements/relations/visualization', :controller=>"re_artifact_relationship", :action=>"visualization"
  map.connect 'projects/:project_id/requirements/relations/visualization/show', :controller=>"re_artifact_relationship", :action=>"build_json_according_to_user_choice" #FIXME: Refactor method name accordingly

  # nagivation tree
  map.connect 'projects/:project_id/requirements/tree/treestate', :controller=>"requirements", :action => "treestate" #FIXME: Refactor from requirements to settings controller
  map.connect 'projects/:project_id/requirements/tree/treestate/:id', :controller=>"requirements", :action => "treestate" #FIXME: Refactor from requirements to settings controller
  map.connect 'projects/requirements/tree/drop', :controller=>"requirements", :action=>"delegate_tree_drop"

  map.connect 'projects/:project_id/relation/prepare/:id', :controller=>"re_artifact_relationship", :action=>"prepare_relationships"
  map.connect 'projects/:project_id/relation/autocomplete/sink/:id', :controller=>"re_artifact_relationship", :action=>"autocomplete_sink"

  map.connect 'projects/:project_id/requirements/artifact/autocomplete/issue', :controller=>"re_artifact_properties", :action=>"autocomplete_issue"
  map.connect 'projects/:project_id/issues/new/connected_to/:artifacttype/:associationid', :controller=>"issues", :action=>"new"

  map.connect 'projects/:project_id/requirements/artifact/autocomplete/artifact', :controller=>"re_artifact_properties", :action=>"autocomplete_artifact"

  map.resources :re_artifact_properties, :as => "artifact", :controller => "re_artifact_properties", :except => [:show, :new, :index]

  map.connect 'artifact/:id/rate/:stars', :controller => "re_artifact_properties", :action => "rate_artifact"

  map.connect 'projects/:project_id/requirements/artifact/new/:artifact_type', :controller=>"re_artifact_properties", :action=>"new"
  map.connect 'projects/:project_id/requirements/artifact/new/:artifact_type/inside_of/:parent_artifact_id', :controller=>"re_artifact_properties", :action=>"new"
  map.connect 'projects/:project_id/requirements/artifact/new/:artifact_type/below_of/:sibling_artifact_id', :controller=>"re_artifact_properties", :action=>"new"

  map.resources :re_queries, :path_prefix => '/projects/:project_id',
    :member => { :delete => :get },
    :collection => {
      :apply => :post,
      :suggest_artifacts => :get,
      :suggest_issues => :get,
      :suggest_users => :get,
      :artifacts_bits => :get,
      :issues_bits => :get,
      :users_bits => :get
    }
end
