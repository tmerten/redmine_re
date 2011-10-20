module ReTaskHelper
  def add_subtask_link(name, element_id , add_pos)
    choosed_icon = add_pos;
    choosed_icon = "after"  if add_pos == "bottom"
    choosed_icon = "before" if add_pos == "top"

    #link_to name, "#", :class => "icon icon-subtask-#{choosed_icon}", :onclick => "addSubtask('#{element_id}', '#{add_pos}');return false;"
    link_to name, "#", :class => "icon icon-subtask-#{choosed_icon}", :onclick => "alert('sorry, to be re-implemented', '#{add_pos}');return false;"
  end
end
