module ReTaskHelper
  def add_subtask_link(name, container, add_pos)
    choosed_icon = "after"  if add_pos == "bottom"
    choosed_icon = "before" if add_pos == "top"

    link_to_function( name, nil, :class => "icon icon-subtask-#{choosed_icon}") do |page|
      page.insert_html add_pos, container, :partial => 're_subtask', :object => ReSubtask.new, :locals => { :new_time}
      page.call 'updateAllSubtaskPositions'
    end
  end
end