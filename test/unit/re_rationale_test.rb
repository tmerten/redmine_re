require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ReRationaleTest < ActiveSupport::TestCase
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
    [:re_rationales])

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
