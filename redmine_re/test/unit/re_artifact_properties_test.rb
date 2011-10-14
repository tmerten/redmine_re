require File.dirname(__FILE__) + '/../test_helper'

class ReArtifactPropertiesTest < ActiveSupport::TestCase
  fixtures :re_artifact_properties, :re_goals, :projects

  def setup

  end


  def test_each_artifact_has_properties
    goals = ReGoal.all
    goal = goals.first

    re_artifact_properties = []
    goals.each { |goal| re_artifact_properties << goal.re_artifact_properties }
    assert re_artifact_properties.count == goals.count, "each goal artifact should have artifact properties"


    workarea = ReWorkarea.new
    wo_properties = workarea.artifact_properties

    assert( ! workarea.re_artifact_properties.nil?, "the newly created workarea should be associated with ReArtifactProperties" )
    #assert( wo_properties.artifact.equal?(workarea), "the newly created properties should be associated with the workarea" )
    assert( workarea.new_record?, "workarea unsaved, yet" )

    workarea.save

    workarea.errors.each { |k,v| Rails::logger.debug("#{self}: errors on first save ########### #{k} -> #{v}") }

    assert( workarea.re_artifact_properties.errors.on(:project) )
    assert( workarea.re_artifact_properties.errors.on(:name) )
#    assert( workarea.re_artifact_properties.errors.on(:artifact) )
    assert( workarea.new_record?, "workarea unsaved, yet" )

    workarea.save
#    assert( workarea.re_artifact_properties.errors.on(:artifact).nil?, "artifact properties should be built automatically" )
    assert( workarea.new_record?, "workarea unsaved, yet" )

    workarea.name = "in-house-testing"
    workarea.save
    assert( workarea.re_artifact_properties.errors.on(:name).nil?, "if a name is set there should be no error" )
    assert( workarea.new_record?, "workarea unsaved, yet" )

    workarea.project = Project.find(1)
    workarea.save

    workarea.re_artifact_properties.parent = goal.re_artifact_properties

    workarea.save
    assert( workarea.re_artifact_properties.errors.on(:project).nil?, "if a name is set there should be no error" )

    workarea.errors.each { |k,v| Rails::logger.debug("#{self}: errors after last save ########### #{k} -> #{v}") }
    assert( workarea.re_artifact_properties.errors.empty?, "with name, artifact, parent and project there should not be an error" )
    assert( ! workarea.re_artifact_properties.nil? , "Each artifact should have properties after save" )
  end

  def test_deletion
    workarea = ReWorkarea.find( Fixtures.identify(:workarea_learning_at_home) )
    goal = ReGoal.find( Fixtures.identify(:goal_usability) )
    wo_re_artifact_properties = workarea.re_artifact_properties
    assert( ! wo_re_artifact_properties.nil? , "the workarea should have properties after save" )

    assert_raise NoMethodError, "artifacts are not deleteable, only artifact_properties" do
      workarea.delete
    end

    workarea.parent= goal.re_artifact_properties
    workarea.save
    workarea.errors.each { |k,v| Rails::logger.debug("#{self}: errors ########### #{k} -> #{v}") }

    assert( ! workarea.new_record?, "should be saved" )
    assert( ! wo_re_artifact_properties.new_record?, "should be saved" )
    assert( ! workarea.frozen?, "the workarea is not yet deleted" )
    assert( ! wo_re_artifact_properties.frozen?, "the artifact is not yet deleted" )
    wo_re_artifact_properties.destroy
    assert( wo_re_artifact_properties.frozen?, "the artifact is deleted" )
    assert( wo_re_artifact_properties.artifact.frozen?, "the artifacts workarea is deleted" )

    artifact = ReArtifactProperties.all[2]
    parent = ReArtifactProperties.all[1]
    dependend = ReArtifactProperties.all[3]
    part_of = ReArtifactProperties.all[4]

    artifact.relate_to(dependend, :dependency)
    artifact.relate_to(part_of, :part_of)
    artifact.set_parent(parent)

    artifact.destroy

    assert( ! parent.frozen?, "related artifacts should not be destroyed" )
    assert( ! dependend.frozen?, "related artifacts should not be destroyed" )
    assert( ! part_of.frozen?, "related artifacts should not be destroyed" )

    artifact.relationships_as_source.each do |rel|
      assert( rel.frozen?, "all relations should be destoyed if an artifact is destroyed #{rel.relation_type.to_s}" )
    end
    artifact.relationships_as_sink.each do |rel|
      assert( rel.frozen?, "all relations should be destoyed if an artifact is destroyed #{rel.relation_type.to_s}" )
    end

  end
end
