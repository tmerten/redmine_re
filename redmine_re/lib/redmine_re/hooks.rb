module RedmineRe

  module Hooks
    class ViewIssuesHook < Redmine::Hook::ViewListener
      render_on(:view_issues_show_description_bottom, :partial => 'issues/show_related_artifacts')
      render_on(:view_issues_edit_notes_bottom, :partial => 'issues/autocomplete_artifacts')
    end
  end


end