module RedmineRe

  module Hooks
    class ViewIssuesHook < Redmine::Hook::ViewListener
      render_on(:view_issues_show_description_bottom, :partial => 'issues/show_related_artifacts')
    end
  end


end