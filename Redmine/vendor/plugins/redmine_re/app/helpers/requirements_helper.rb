module RequirementsHelper

    # options may contain :method and html-options
    def context_menu_link_remote (name, url, update, options={})
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
