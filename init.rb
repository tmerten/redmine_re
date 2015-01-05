require 'redmine'
require 'redmine_re/hooks'
require 'rubygems'

require_dependency '../app/models/re_artifact_relationship'
require_dependency '../app/models/re_artifact_properties'
require_dependency '../app/models/re_relationtype'
require_dependency '../app/helpers/re_application_helper'

# Make singular and plural for RE_Artifact_Properties the same
ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular /^(ReArtifactPropert)ies/i, '\1ies'
  inflect.plural /^(ReArtifactPropert)ies/i, '\1ies'
end

#ARTIFACT_TYPES = "%w{ReGoal ReSection ReVision ReTask ReSubtask ReVision ReWorkarea ReUserProfile ReSection ReRequirement ReScenario ReProcessword ReRational ReUseCase ReRationale Project}"

#Rails.configuration.to_prepare do
ActionDispatch::Callbacks.to_prepare do
  # redmine_re patches
  require_dependency 'issue_patch'
  require_dependency 'issue_controller_patch'
  require_dependency 'mailer_patch'
  require_dependency 'query_patch'
  require_dependency 'role_patch'
  require_dependency 'project_patch'
  require_dependency 'projects_controller_patch'
  require_dependency 'user_patch'
end

require_dependency '../lib/re_wiki_macros'

ActionView::Base.class_eval do
  include ReApplicationHelper
end

Redmine::Plugin.register :redmine_re do
  name 'Redmine Requirements Engineering Plugin'
  author 'Bonn-Rhine-Sieg University of Applied Sciences (thorsten.merten@h-brs.de)'
  description 'This is a plugin to handle requirements engineering artifacts within redmine. The plugin has been developed
within the KoREM project (http://korem.de) at Bonn-Rhine-Sieg University of Applied Sciences (http://h-brs.de)'
  version 'development version'
  url 'http://redmine.korem.de'
  author_url 'http://korem.de'

  requires_redmine :version_or_higher => '2.1.0'


  # this plugin creates a project module. navigate to 'settings->modules' in the app to activate the plugin per project
  project_module :requirements do
    #   before_filter :authorize is set in the redmine_re_controller
    permission(:view_requirements,
               {
                   :requirements => [:index, :treeview, :treestate, :load_settings,
                                     :find_project, :add_hidden_re_artifact_properties_attributes, :create_tree,
                                     :render_to_html_tree, :render_children_to_html_tree,
                                     :enhanced_filter, :build_conditions_hash, :find_first_artifacts_with_first_parameter,
                                     :reduce_search_result_with_parameter, :sendDiagramPreviewImage],
                   :redmine_re => [:enhanced_filter, :index, :treeview, :treestate, :load_settings,
                                   :find_project, :add_hidden_re_artifact_properties_attributes, :create_tree,
                                   :render_to_html_tree, :render_children_to_html_tree,
                                   :enhanced_filter, :build_conditions_hash, :find_first_artifacts_with_first_parameter,
                                   :reduce_search_result_with_parameter],
                   :re_artifact_properties => [:show, :redirect],
                   :re_artifact_relationship => [:prepare_relationships, :visualization, :build_json_according_to_user_choice],
                   :re_queries => [:index, :show, :query, :apply,
                                   :suggest_artifacts, :suggest_issues, :suggest_diagrams, :suggest_users,
                                   :artifacts_bits, :issues_bits, :diagrams_bits, :users_bits]
               }
    )

    permission(:edit_requirements,
               {
                   :requirements => [:index, :treeview, :context_menu, :treestate, :load_settings,
                                     :find_project, :add_hidden_re_artifact_properties_attributes, :create_tree,
                                     :delegate_tree_drop, :render_to_html_tree, :render_children_to_html_tree,
                                     :enhanced_filter, :build_conditions_hash, :find_first_artifacts_with_first_parameter,
                                     :reduce_search_result_with_parameter, :sendDiagramPreviewImage, :add_relation],
                   :redmine_re => [:enhanced_filter, :index, :treeview, :context_menu, :treestate, :load_settings,
                                   :find_project, :add_hidden_re_artifact_properties_attributes, :create_tree,
                                   :delegate_tree_drop, :render_to_html_tree, :render_children_to_html_tree,
                                   :enhanced_filter, :build_conditions_hash, :find_first_artifacts_with_first_parameter,
                                   :reduce_search_result_with_parameter],
                   :re_artifact_properties => [:show, :new, :create, :update, :edit, :redirect, :destroy, :autocomplete_parent, :autocomplete_issue,
                                               :autocomplete_artifact, :remove_issue_from_artifact, :remove_artifact_from_issue,
                                               :rate_artifact, :how_to_delete, :recursive_destroy, :new_comment],
                   :re_artifact_relationship => [:delete, :autocomplete_sink, :prepare_relationships,
                                                 :visualization, :build_json_according_to_user_choice],
                   :re_rationale => [:edit, :new],
                   :re_queries => [:index, :new, :edit, :show, :delete, :create, :update, :query, :apply,
                                   :suggest_artifacts, :suggest_issues, :suggest_diagrams, :suggest_users,
                                   :artifacts_bits, :issues_bits, :diagrams_bits, :users_bits]
               }
    )
    permission(:administrate_requirements,
               {
                   :requirements => [:setup],
                   :re_settings => [:configure, :configure_fields, :edit_artifact_type_description]
               }
    )

    permission(:comment_on_requirements, {
        :re_artifact_properties => [:new_comment]
    })

    permission(:delete_re_artifact_properties_watchers, {}
    )
  end

  # The Requirements item is added to the project menu after the Activity item
  menu :project_menu, :re, {:controller => 'requirements', :action => 'index'}, :caption => 'Requirements', :after => :activity, :param => :project_id
  activity_provider :re_artifact_properties, :class_name => 'ReArtifactProperties', :default => true

  #settings :default => {'re_artifact_types' => ''}, :partial => 'settings/redmine_re'

  # add "acts_as_re_artifact" method to any ActiveRecord::Base class
  # as an alias to "include Artifact"
  class ActiveRecord::Base
    def self.acts_as_re_artifact
      include Artifact
    end
  end
end