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
  
  
  test "Check if relations during move functions a correct" do
    
    # Fixtures provides the following tree (Project id 5)
    #
    # testartifact_relation_move_root
    #   testartifact_relation_move_l1_1
    #     testartifact_relation_move_l2_1
    #     testartifact_relation_move_l2_2
    #     testartifact_relation_move_l2_3
    #   testartifact_relation_move_l1_2
    
    # Validation tree structure
    project = ReArtifactProperties.find(ActiveRecord::Fixtures.identify(:testartifact_relation_move_root))
    assert_not_nil project, "Test project was not found"
    assert project.id > 0, "Project id is not correct"
    n = ReArtifactRelationship.where(:source_id => project.artifact_id.to_s).count
    assert n == 2, "Project tree structure is not correct "+n.to_s+"/2"
    
    artifact_1_1 = ReArtifactProperties.find(ActiveRecord::Fixtures.identify(:testartifact_relation_move_l1_1))
    assert_not_nil artifact_1_1, "Artifact 1_1 was not found"
    assert artifact_1_1.id > 0, "Artifact 1_1 id is not correct"
    n = ReArtifactRelationship.where(:source_id => artifact_1_1.artifact_id.to_s).count
    assert n == 3, "Project tree structure is not correct "+n.to_s+"/3"
    
    # Tree structure is valid
    
    
    
    
    # sibling_id = params[:sibling_id]
    # moved_artifact_id = params[:id]
    # insert_position = params[:position]
# 
    # moved_artifact = ReArtifactProperties.find(moved_artifact_id)
# 
    # new_parent = nil
    # sibling = ReArtifactProperties.find(sibling_id)
    # position = 1
#     
    # case insert_position
      # when 'before'
        # position = (sibling.position - 1) unless sibling.nil?
        # new_parent = sibling.parent
      # when 'after'
        # position = (sibling.position + 1) unless sibling.nil?
        # new_parent = sibling.parent
      # when 'inside'
        # position = 1
        # new_parent = sibling
      # else
        # render :text => "insert position invalid", :status => 501
    # end
    # session[:expanded_nodes] << new_parent.id
#  
    # building_block_data = ReBbDataArtifactSelection.find(:first, :conditions => {:re_artifact_relationship_id => moved_artifact.parent_relation.id})
    # building_block_data.delete unless building_block_data.nil?
    # moved_artifact.parent_relation.remove_from_list
    # moved_artifact.parent = new_parent
    # moved_artifact.parent_relation.insert_at(position)
      
  end
end