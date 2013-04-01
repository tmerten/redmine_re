require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ReArtifactPropertiesTest < ActiveSupport::TestCase
  test "Plural RAP-Model should be the same like singular" do
    assert_equal("ReArtifactProperties".pluralize, "ReArtifactProperties", "not the same")
  end

  test "Singular RAP-Model should be the same like plural" do
    assert_equal("ReArtifactProperties".singularize, "ReArtifactProperties", "not the same")
  end
end