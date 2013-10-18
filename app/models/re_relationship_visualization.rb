class ReRelationshipVisualization < ActiveRecord::Base
 
  def filter_table_add_row(projekt_id, visualization_type, visualization_artefakt_id)
    insert_re_relationship_visualization = ReRelationshipVisualization.new
    
    insert_re_relationship_visualization.project_id = projekt_id
    insert_re_relationship_visualization.visualization_typ = visualization_type
    insert_re_relationship_visualization.artefakt_id = visualization_artefakt_id
    insert_re_relationship_visualization.user_id = User.current.id

    relation_settings = ReSetting.get_serialized("re_goal", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_goal = 1 
    else
      insert_re_relationship_visualization.re_goal  = 0
    end
   
    relation_settings = ReSetting.get_serialized("re_processword", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_processword = 1 
    else
      insert_re_relationship_visualization.re_processword  = 0
    end

    relation_settings = ReSetting.get_serialized("re_rationale", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_rationale = 1 
    else
      insert_re_relationship_visualization.re_rationale  = 0
    end
   
    relation_settings = ReSetting.get_serialized("re_requirement", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_requirement = 1 
    else
      insert_re_relationship_visualization.re_requirement  = 0
    end

    relation_settings = ReSetting.get_serialized("re_scenario", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_scenario = 1 
    else
      insert_re_relationship_visualization.re_scenario  = 0
    end

    relation_settings = ReSetting.get_serialized("re_section", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_section = 1 
    else
      insert_re_relationship_visualization.re_section  = 0
    end

    relation_settings = ReSetting.get_serialized("re_task", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_task = 1 
    else
      insert_re_relationship_visualization.re_task  = 0
    end

    relation_settings = ReSetting.get_serialized("re_user_profile", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_user_profile = 1 
    else
      insert_re_relationship_visualization.re_user_profile  = 0
    end

    relation_settings = ReSetting.get_serialized("re_use_case", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_use_case = 1 
    else
      insert_re_relationship_visualization.re_use_case  = 0
    end

    relation_settings = ReSetting.get_serialized("re_vision", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_vision = 1 
    else
      insert_re_relationship_visualization.re_vision  = 0
    end

    relation_settings = ReSetting.get_serialized("re_workarea", projekt_id)
    if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
       insert_re_relationship_visualization.re_workarea = 1 
    else
      insert_re_relationship_visualization.re_workarea  = 0
    end

    if(visualization_type.to_s!="sunburst")
      
      relation_settings = ReSetting.get_serialized("dependency", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.dependency = 1 
      else
        insert_re_relationship_visualization.dependency  = 0
      end
     
      relation_settings = ReSetting.get_serialized("conflict", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.conflict = 1 
      else
        insert_re_relationship_visualization.conflict  = 0
      end 
     
      relation_settings = ReSetting.get_serialized("rationale", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.rationale = 1 
      else
        insert_re_relationship_visualization.rationale  = 0
      end  
      
      relation_settings = ReSetting.get_serialized("refinement", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.refinement = 1 
      else
        insert_re_relationship_visualization.refinement  = 0
      end 
     
      relation_settings = ReSetting.get_serialized("part_of", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.part_of = 1 
      else
        insert_re_relationship_visualization.part_of  = 0
      end 
      
      relation_settings = ReSetting.get_serialized("parentchild", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.parentchild = 1 
      else
        insert_re_relationship_visualization.parentchild  = 0
      end 
     
      relation_settings = ReSetting.get_serialized("primary_actor", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.primary_actor = 1 
      else
        insert_re_relationship_visualization.primary_actor  = 0
      end 
      
      relation_settings = ReSetting.get_serialized("actors", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.actors = 1 
      else
        insert_re_relationship_visualization.actors  = 0
      end 

      relation_settings = ReSetting.get_serialized("diagram", projekt_id)
      if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
         insert_re_relationship_visualization.diagram = 1 
      else
        insert_re_relationship_visualization.diagram  = 0
      end 
    else
      insert_re_relationship_visualization.dependency = 0
      insert_re_relationship_visualization.conflict = 0
      insert_re_relationship_visualization.rationale = 0
      insert_re_relationship_visualization.refinement = 0
      insert_re_relationship_visualization.part_of = 0
      insert_re_relationship_visualization.parentchild = 1
      insert_re_relationship_visualization.primary_actor = 0
      insert_re_relationship_visualization.actors = 0
      insert_re_relationship_visualization.diagram = 0
    end
    
    issue = ReSetting.get_plain("issues", projekt_id)
    if (issue == "yes" || issue == true)
        insert_re_relationship_visualization.issue = 1
    else
        insert_re_relationship_visualization.issue = 0
    end
    insert_re_relationship_visualization.max_deep = ReSetting.get_plain("visualization_deep", projekt_id).to_i
    if(visualization_type.to_s=="netmap")
      insert_re_relationship_visualization.max_deep = 0
    end
    
    insert_re_relationship_visualization.save
  end
 
  def relationship_save(project_id,artifact_array,visualization_type,visualization_artefakt_id)
    @check_if_filter_are_save_befor = ReRelationshipVisualization.where(
        "project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",
        {:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}
      ).first
  
    @update_re_relationship_visualization=ReRelationshipVisualization.find_by_id(@check_if_filter_are_save_befor.id)
    
    artifact_array.each do |item|
      if item == "dep"
        @update_re_relationship_visualization.dependency = 1
        break
      else
        @update_re_relationship_visualization.dependency = 0
      end
    end
    artifact_array.each do |item|
      if item == "con"
        @update_re_relationship_visualization.conflict = 1
        break
      else
        @update_re_relationship_visualization.conflict = 0
      end
    end
    artifact_array.each do |item|
      if item == "rat"
        @update_re_relationship_visualization.rationale = 1
        break
      else
        @update_re_relationship_visualization.rationale = 0
      end
    end
    artifact_array.each do |item|
      if item == "ref"
        @update_re_relationship_visualization.refinement = 1
        break
      else
        @update_re_relationship_visualization.refinement = 0
      end
    end
    artifact_array.each do |item|
      if item == "pof"
        @update_re_relationship_visualization.part_of = 1
        break
      else
        @update_re_relationship_visualization.part_of = 0
      end
    end
    artifact_array.each do |item|
      if item == "pch"
        @update_re_relationship_visualization.parentchild = 1
        break
      else
        @update_re_relationship_visualization.parentchild = 0
      end
    end
    artifact_array.each do |item|
      if item == "pac"
        @update_re_relationship_visualization.primary_actor = 1
        break
      else
        @update_re_relationship_visualization.primary_actor = 0
      end
    end
    artifact_array.each do |item|
      if item == "ac"
        @update_re_relationship_visualization.actors = 1
        break
      else
        @update_re_relationship_visualization.actors = 0
      end
    end
    artifact_array.each do |item|
      if item == "dia"
        @update_re_relationship_visualization.diagram = 1
        break
      else
        @update_re_relationship_visualization.diagram = 0
      end
    end
    artifact_array.each do |item|
      if item == "issue"
        @update_re_relationship_visualization.issue = 1
        break
      else
        @update_re_relationship_visualization.issue = 0
      end
    end
    @update_re_relationship_visualization.save
  end
  
  def artifact_save(project_id,artifact_array,visualization_type,visualization_artefakt_id)
    @check_if_filter_are_save_befor = ReRelationshipVisualization.where(
        "project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",
        {:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}
      ).first
  
    @update_re_relationship_visualization=ReRelationshipVisualization.find_by_id(@check_if_filter_are_save_befor.id)
    
    artifact_array.each do |item|
      if item == "re_attachment"
        @update_re_relationship_visualization.re_attachment = 1
        break
      else
        @update_re_relationship_visualization.re_attachment = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_goal"
        @update_re_relationship_visualization.re_goal = 1
        break
      else
        @update_re_relationship_visualization.re_goal = 0
      end
    end
   artifact_array.each do |item|
     if item == "re_processword"
        @update_re_relationship_visualization.re_processword = 1
        break
      else
        @update_re_relationship_visualization.re_processword = 0
      end
    end
    
    artifact_array.each do |item|
      if item == "re_rationale"
        @update_re_relationship_visualization.re_rationale = 1
        break
      else
        @update_re_relationship_visualization.re_rationale = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_requirement"
        @update_re_relationship_visualization.re_requirement = 1
        break
      else
        @update_re_relationship_visualization.re_requirement = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_scenario"
        @update_re_relationship_visualization.re_scenario = 1
        break
      else
        @update_re_relationship_visualization.re_scenario = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_section"
        @update_re_relationship_visualization.re_section = 1
        break
      else
        @update_re_relationship_visualization.re_section = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_task"
        @update_re_relationship_visualization.re_task = 1
        break
      else
        @update_re_relationship_visualization.re_task = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_user_profile"
        @update_re_relationship_visualization.re_user_profile = 1
        break
      else
        @update_re_relationship_visualization.re_user_profile = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_use_case"
        @update_re_relationship_visualization.re_use_case = 1
        break
      else
        @update_re_relationship_visualization.re_use_case = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_vision"
        @update_re_relationship_visualization.re_vision = 1
        break
      else
        @update_re_relationship_visualization.re_vision = 0
      end
    end
    artifact_array.each do |item|
      if item == "re_workarea"
        @update_re_relationship_visualization.re_workarea = 1
        break
      else
        @update_re_relationship_visualization.re_workarea = 0
      end
    end
    artifact_array.each do |item|
      if item == "issue"
        @update_re_relationship_visualization.issue = 1
        break
      else
        @update_re_relationship_visualization.issue = 0
      end
    end
    @update_re_relationship_visualization.save
  end
  
  def get_artifact_filter_as_stringarray(project_id,visualization_type,visualization_artefakt_id)
    @saved_filter = ReRelationshipVisualization.where("project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",{:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}).first
      @choosen_artifacts = []
      
      if @saved_filter.re_attachment == 1 
        @choosen_artifacts << "ReAttachment"
      end
      if @saved_filter.re_goal == 1 
        @choosen_artifacts << "ReGoal"
      end
      if @saved_filter.re_processword == 1 
        @choosen_artifacts << "ReProcessword"
      end
      if @saved_filter.re_rationale == 1 
        @choosen_artifacts << "ReRationale"
      end
      if @saved_filter.re_requirement == 1 
        @choosen_artifacts << "ReRequirement"
      end
      if @saved_filter.re_scenario == 1 
        @choosen_artifacts << "ReScenario"
      end
      if @saved_filter.re_section == 1 
        @choosen_artifacts << "ReSection"
      end
      if @saved_filter.re_task == 1 
        @choosen_artifacts << "ReTask"
      end
      if @saved_filter.re_use_case == 1 
        @choosen_artifacts << "ReUseCase"
      end
      
      if @saved_filter.re_user_profile == 1 
        @choosen_artifacts << "ReUserProfile"
      end
      if @saved_filter.re_vision == 1 
        @choosen_artifacts << "ReVision"
      end
      if @saved_filter.re_workarea == 1
        @choosen_artifacts << "ReWorkarea"
      end    
  
      return @choosen_artifacts
    
  end
   
  def get_relation_filter_as_stringarray(project_id,visualization_type,visualization_artefakt_id)
    @saved_filter = ReRelationshipVisualization.where("project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",{:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}).first
    
    @choosen_relation = []
   
    if @saved_filter.dependency == 1 
      @choosen_relation << "dependency"
    end
    if @saved_filter.conflict == 1 
      @choosen_relation << "conflict"
    end
    if @saved_filter.rationale == 1 
      @choosen_relation << "rationale"
    end
    if @saved_filter.refinement == 1 
      @choosen_relation << "refinement"
    end
    if @saved_filter.part_of == 1 
      @choosen_relation << "part_of"
    end
  
    if @saved_filter.parentchild == 1 
      @choosen_relation << "parentchild"
    end
    if @saved_filter.primary_actor == 1 
      @choosen_relation << "primary_actor"
    end
    if @saved_filter.actors == 1 
      @choosen_relation << "actors"
    end
    if @saved_filter.diagram == 1 
      @choosen_relation << "diagram"
    end
    
    return @choosen_relation
  end
  
  def set_filter_for_visualization(project_id,visualization_type,visualization_artefakt_id,artefakt_name)
    
    @get_row_re_relationship_visualization = ReRelationshipVisualization.where("project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",{:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}).first

      if artefakt_name == "re_attachment" && @get_row_re_relationship_visualization.re_attachment == 1
         return true 
      end
      if artefakt_name == "re_goal" && @get_row_re_relationship_visualization.re_goal == 1
         return true 
      end
      if artefakt_name == "re_processword" && @get_row_re_relationship_visualization.re_processword == 1
         return true 
      end
      if artefakt_name == "re_rationale" && @get_row_re_relationship_visualization.re_rationale == 1
         return true 
      end 
      if artefakt_name == "re_requirement" && @get_row_re_relationship_visualization.re_requirement == 1
         return true 
      end
      if artefakt_name == "re_scenario" && @get_row_re_relationship_visualization.re_scenario == 1
         return true 
      end
      if artefakt_name == "re_section" && @get_row_re_relationship_visualization.re_section == 1
         return true 
      end
      if artefakt_name == "re_task" && @get_row_re_relationship_visualization.re_task == 1
         return true 
      end
      if artefakt_name == "re_user_profile" && @get_row_re_relationship_visualization.re_user_profile == 1
         return true 
      end
      if artefakt_name == "re_use_case" && @get_row_re_relationship_visualization.re_use_case == 1
         return true 
      end
      if artefakt_name == "re_vision" && @get_row_re_relationship_visualization.re_vision == 1
         return true 
      end
      if artefakt_name == "re_workarea" && @get_row_re_relationship_visualization.re_workarea == 1
         return true 
      end
      
      if artefakt_name == "dependency" && @get_row_re_relationship_visualization.dependency == 1
         return true 
      end
      if artefakt_name == "conflict" && @get_row_re_relationship_visualization.conflict == 1
         return true 
      end
      if artefakt_name == "rationale" && @get_row_re_relationship_visualization.rationale == 1
         return true 
      end
      if artefakt_name == "refinement" && @get_row_re_relationship_visualization.refinement == 1
         return true 
      end
      if artefakt_name == "part_of" && @get_row_re_relationship_visualization.part_of == 1
         return true 
      end
      
      if artefakt_name == "parentchild" && @get_row_re_relationship_visualization.parentchild == 1
         return true 
      end
      if artefakt_name == "primary_actor" && @get_row_re_relationship_visualization.primary_actor == 1
         return true 
      end
      if artefakt_name == "actors" && @get_row_re_relationship_visualization.actors == 1
         return true 
      end
      if artefakt_name == "diagram" && @get_row_re_relationship_visualization.diagram == 1
         return true 
      end
      if artefakt_name == "issue" && @get_row_re_relationship_visualization.issue == 1
        return true
      end
        
      return false 
  end
  
  def get_issue_filter(project_id, visualization_type, visualization_artefakt_id)
    saved_filter = ReRelationshipVisualization.where("project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",{:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}).first
    if saved_filter.issue == 1
      return true
    end
    return false
  end
  
  def get_max_deep(project_id, visualization_type, visualization_artefakt_id)
    saved = ReRelationshipVisualization.where("project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",{:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}).first
    return saved.max_deep
  end
  
  def save_max_deep(project_id,max_deep,visualization_type,visualization_artefakt_id)
    @check_if_filter_are_save_befor = ReRelationshipVisualization.where(
        "project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",
        {:project_id => project_id, :visualization_type => visualization_type, :artifact_id => visualization_artefakt_id, :user_id =>User.current.id}
      ).first
  
    @update_re_relationship_visualization=ReRelationshipVisualization.find_by_id(@check_if_filter_are_save_befor.id)
    @update_re_relationship_visualization.max_deep = max_deep
    @update_re_relationship_visualization.save
  end  
  

  
end