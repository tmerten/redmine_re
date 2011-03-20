module RequirementsHelper

  def context_menu_link_remote (name, url, update, options={})
    # This helper creates an remote link for a context-menu
    # Params: name    This String is written on the html page as the link
    #         url     A hash with information about action, controller and parameters
    #         update  Name of the html element which should be updated
    #         options A hash containing one the one hand the html-options for the link
    #                 but the hash may contain :method and :confirm as well. See documentation
    #                 on link_to_remote for html-options.
    # Example: <%= context_menu_link_remote 'Edit',
    #                                           {:controller => @subartifact_controller, :action => 'edit', :id => @artifact.id, :project_id => @artifact.project_id},
    #                                           'detail_view',
    #                                           :method => :get,
    #                                           :class => 'icon-edit',
    #                                           :disabled => false %>
    # Generates: <a onclick="new Ajax.Updater('detail_view', '/re_subtask/edit/2?project_id=1', {asynchronous:true, evalScripts:true, method:'get', parameters:'authenticity_token=' + encodeURIComponent('LpQJtfbJlKJVxpblgb1KKfqpu5vd59APcZR32Hr9vTk=')}); return false;"
    #               href="#"
    #               class="icon-edit">Edit</a>
    options[:class] ||= ''
    if options.delete(:selected)
      options[:class] << ' icon-checked disabled'
      options[:disabled] = true
    end
    if options.delete(:disabled)
      options.delete(:method)
      options.delete(:confirm)
      options.delete(:onclick)
      options[:class] << ' disabled'
      url = '#'
    end
    link_to_remote name, :url => url, :update => update, :method => options.delete(:method), :confirm => options.delete(:confirm), :html => options
  end
end
