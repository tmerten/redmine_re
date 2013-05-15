require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Currently the test dose not work, because sink and source artifact can not be created
# in fact of missing dependings

class ReRelationTest < ActiveSupport::TestCase
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
    [:re_artifact_properties, :re_artifact_relationships])

  test "Test if all relations are deleted, if an source artifact was deleted" do
    assert_not_nil source = ReArtifactProperties.find_by_name("sourceartifact"), "Error during loading of fixtures"
    assert_not_nil sink = ReArtifactProperties.find_by_name("sinkartifact"), "Error during loading of fixtures"
    
    # System relations
    new_pch_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "parentchild" )
    new_pch_relation.save()
    pch_id = new_pch_relation.id
    
    new_pac_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "primary_actor" )
    new_pac_relation.save()
    pac_id = new_pac_relation.id
    
    new_ac_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "actors" )
    new_ac_relation.save()
    ac_id = new_ac_relation.id
    
    new_dia_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "diagram" )
    new_dia_relation.save()
    dia_id = new_dia_relation.id
    
    # Relations
    new_dep_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "dependency" )
    new_dep_relation.save()
    dep_id = new_dep_relation.id
    
    new_con_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "conflict" )
    new_con_relation.save()
    con_id = new_con_relation.id
    
    new_rat_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "rationale" )
    new_rat_relation.save()
    rat_id = new_rat_relation.id
    
    new_ref_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "refinement" )
    new_ref_relation.save()
    ref_id = new_ref_relation.id
    
    new_pof_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "part_of" )
    new_pof_relation.save()
    pof_id = new_pof_relation.id
    
    source.destroy()
    
    assert_nil ReArtifactRelationship.find_by_id(pch_id), "Parentchild relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(pac_id), "Primari actor relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(ac_id),  "Actor relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(dia_id), "Diagram relation was not deleted, when source artifact was deleted."
       
    assert_nil ReArtifactRelationship.find_by_id(dep_id), "Dependency relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(con_id), "Conflic relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(rat_id), "Rationale relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(ref_id), "Refinement relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(pof_id), "Part of relation was not deleted, when source artifact was deleted."

  end

  test "Test if all relations are deleted, if an sink artifact was deleted" do
    assert_not_nil source = ReArtifactProperties.find_by_name("sourceartifact"), "Error during loading of fixtures"
    assert_not_nil sink = ReArtifactProperties.find_by_name("sinkartifact"), "Error during loading of fixtures"
        
    # System relations
    new_pch_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "parentchild" )
    new_pch_relation.save()
    pch_id = new_pch_relation.id
    
    new_pac_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "primary_actor" )
    new_pac_relation.save()
    pac_id = new_pac_relation.id
    
    new_ac_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "actors" )
    new_ac_relation.save()
    ac_id = new_ac_relation.id
    
    new_dia_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "diagram" )
    new_dia_relation.save()
    dia_id = new_dia_relation.id
    
    # Relations
    new_dep_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "dependency" )
    new_dep_relation.save()
    dep_id = new_dep_relation.id
    
    new_con_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "conflict" )
    new_con_relation.save()
    con_id = new_con_relation.id
    
    new_rat_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "rationale" )
    new_rat_relation.save()
    rat_id = new_rat_relation.id
    
    new_ref_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "refinement" )
    new_ref_relation.save()
    ref_id = new_ref_relation.id
    
    new_pof_relation = ReArtifactRelationship.new(:sink_id => sink.id, :source_id => source.id, :relation_type => "part_of" )
    new_pof_relation.save()
    pof_id = new_pof_relation.id
    
    sink.destroy()
    
    assert_nil ReArtifactRelationship.find_by_id(pch_id), "Parentchild relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(pac_id), "Primari actor relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(ac_id),  "Actor relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(dia_id), "Diagram relation was not deleted, when source artifact was deleted."
       
    assert_nil ReArtifactRelationship.find_by_id(dep_id), "Dependency relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(con_id), "Conflic relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(rat_id), "Rationale relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(ref_id), "Refinement relation was not deleted, when source artifact was deleted."
    assert_nil ReArtifactRelationship.find_by_id(pof_id), "Part of relation was not deleted, when source artifact was deleted."
  end
    
end