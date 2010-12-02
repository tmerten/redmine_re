class RequirementsController < RedmineReController
  unloadable

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper

  def index
    @htmltree = create_tree
  end

end