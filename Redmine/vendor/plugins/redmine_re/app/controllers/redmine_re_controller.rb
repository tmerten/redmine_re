##
# super controller for the redmine RE plugin
# common methods used for (almost) all redmine_re controllers go here
class RedmineReController < ApplicationController
  unloadable

  before_filter :find_project

  #before_filter :authorize,
               # :except =>  [:delegate_tree_drop, :delegate_tree_node_click]

  layout proc{ |c| c.request.xhr? ? false : "base" } # uses Redmines Base layout for the header unless it is an ajax-request
  menu_item :re # marks 'Requirements' (css class=re) as the selected menu item

  ##
  # find the current project either by project name (project id entered by the user) or id
  def find_project
    project_id = params[:project_id]
    return unless project_id
    begin
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  ##
  # this adds user-unmodifiable attributes to the re_artifact
  # the re_artifact is a superclass of all other artifacts (goals, tasks, etc)
  # this method should be called after initializing or loading any artifact object
  def add_hidden_re_artifact_attributes re_artifact
    author = find_current_user
    re_artifact.project_id = @project.id
    re_artifact.author_id = author.id
    re_artifact.updated_at = Time.now
  end

end