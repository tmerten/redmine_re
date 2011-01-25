class RequirementsController < RedmineReController
  unloadable
  menu_item :re

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper

  def index
    @html_tree = create_tree
  end

end