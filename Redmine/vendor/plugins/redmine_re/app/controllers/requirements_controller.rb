class RequirementsController < RedmineReController
  unloadable
  menu_item :re

  def index
    @html_tree = create_tree
  end

end