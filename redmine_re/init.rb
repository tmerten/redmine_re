require 'redmine'
require 'redmine_re/hooks'
require 'dispatcher'
require 'rubygems'
require 'gchart'

Dispatcher.to_prepare do
  require_dependency 'issue_patch'
  require_dependency 'issue_controller_patch'
  require_dependency 'ajaxful_rating_patch'
  require_dependency 'user_patch'
end

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

    #   before_filter :authorize is set in the redmine_re_controller
		permission( :edit_requirements,
      {
        # actions of redmine_re_controller are here too because the get executed by inheritance of requirements controller
        # for example here:_tree partial: <%= url_for :controller => 'requirements', :action => 'context_menu' %>
        :requirements => [:index, :treeview, :context_menu, :treestate, :load_settings,
          :find_project, :add_hidden_re_artifact_properties_attributes, :create_tree,
          :delegate_tree_drop, :render_to_html_tree, :render_children_to_html_tree,
          :enhanced_filter, :build_conditions_hash, :find_first_artifacts_with_first_parameter,
          :reduce_search_result_with_parameter ],
        :re_artifact_properties => [:edit, :redirect, :delete, :autocomplete_parent, :autocomplete_issue, :autocomplete_artifact, :remove_issue_from_artifact, :remove_artifact_from_issue, :rate_artifact],
        :re_goal => [:edit, :new] ,
        :re_task => [:edit, :new, :delete_subtask],
        :re_subtask => [:edit, :new],
        :re_section => [:edit, :new],
        :re_workarea => [:edit, :new],
        :re_scenario => [:edit, :new],
        :re_vision => [:edit, :new],
        :re_user_profile => [:edit, :new],
        :re_settings => [:edit, :configure, :children],
        :re_attachment => [:edit, :new, :download_or_show, :delete_file],
        :re_processword => [:edit, :new],
        :re_requirement => [:edit, :new],
        :re_artifact_relationship => [:delete, :autocomplete_sink, :prepare_relationships,
          :visualization, :build_json_according_to_user_choice],
      
      }
    )
    permission( :administrate_requirements,
      {
        :requirements => [:setup, :configure],
        :re_settings => [:configure_fields],
        :re_building_block => [:edit, :new, :update_config_form, :delete_data, 
          :react_to_change_in_field_multiple_values, :re_building_block_referred_artifact_types,
          :react_to_check_of_embedding_type_attributes, :react_to_change_in_data_field_artifact_type,
          :react_to_change_in_field_referred_artifact_types]
      }
    )
	end

	# The Requirements item is added to the project menu after the Activity item
	menu :project_menu, :re, { :controller => 'requirements', :action => 'index' }, :caption => 'Requirements', :after => :activity, :param => :project_id

	activity_provider :re_artifact_properties, :class_name => 'ReArtifactProperties', :default => true
	
	# ReArtifactProperties can be added to the activity view
	#activity_provider :re_artifact_properties

	#Observers
	config.active_record.observers = :re_artifact_properties_observer

  config.gem "ajaxful_rating_jquery"
	#ActiveSupport::Dependencies.load_once_paths.delete(File.expand_path(File.dirname(__FILE__))+'/lib')

	# add "acts_as_re_artifact" method to any ActiveRecord::Base class
	# as an alias to "include Artifact"
	settings :default => {
    're_artifact_types' => ''
  }, :partial => 'settings/re_settings'

	class ActiveRecord::Base
		def self.acts_as_re_artifact
			include Artifact
		end
  end
end

config.after_initialize do
  #initialize_re_artifact_order
end