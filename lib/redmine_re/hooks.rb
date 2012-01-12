module RedmineRe

  module Hooks
    class ViewIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_description_bottom, :partial => 'issues/show_related_artifacts'
      render_on :view_issues_form_details_bottom, :partial => 'issues/autocomplete_artifacts'

      # Artifacts Submenu in Issues Context Menu
      render_on :view_issues_context_menu_end, :partial => 'issues/artifacts_context_menu'
      render_on :view_issues_index_bottom, :partial => 'issues/re_stylesheets'
    end
  end


end