require 'redmine'

Redmine::Plugin.register :redmine_re do
  name 'Redmine Requirements Engineering Plugin'
  author 'Bonn-Rhine-Sieg University of Applied Sciences (thorsten.merten@h-brs.de)'
  description 'This is a plugin to handle requirements engineering artifacts within redmine. The plugin has been developed
within the KoREM project (http://korem.de) at Bonn-Rhine-Sieg University of Applied Sciences (http://h-brs.de)'
  version '0.0.1'
  url 'http://korem.de/redmineplugin'
  author_url 'http://korem.de'

  # this plugin creates a project module. navigate to 'settings->modules' in the app to activate the plugin per project
  project_module :requirements do
    permission( :re,
      {
        :requirements => [:index, :treeview],
        :re_goal => [:index, :edit, :new, :delete] ,
        :re_task => [:index, :edit, :new, :delete, :show_versions, :change_version] ,
        :re_subtask => [:index, :edit, :new, :delete, :show_versions, :change_version, :create, :update]
      },
      :public => true
    )

    # more restrictive setup manage_requirements becomes "Manage Requirements" by convention
    # permission :manage_requirements, :requirements => :index
  end

  # The Requirements item is added to the project menu after the Activity item
  menu :project_menu, :re, { :controller => 'requirements', :action => 'index' }, :caption => 'Requirements', :after => :activity, :param => :project_id
  #menu :project_menu, :re, { :controller => 'requirements', :action => 'index' }, :caption => 'Requirements', :after => :activity, :param => :project_id

  # ReArtifact can be added to the activity view
  #activity_provider :re_artifact

  #Observers
  config.active_record.observers = :re_artifact_observer
end