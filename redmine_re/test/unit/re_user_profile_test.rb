require File.dirname(__FILE__) + '/../test_helper'

class ReUserProfileTest < ActiveSupport::TestCase
  fixtures :re_user_profiles

  def setup
    @ecookbook = Project.find(1)
    @ecookbook_sub1 = Project.find(3)
    User.current = nil
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
