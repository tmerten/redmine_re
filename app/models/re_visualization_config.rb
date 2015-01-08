class ReVisualizationConfig < ActiveRecord::Base
  unloadable
 
  
   def self.save_visualization_config (project_id, artifact_array, relation_array, visualization_type)
      ReVisualizationConfig.destroy_all(:project_id => project_id, :user_id => User.current.id, :visualization_type => visualization_type)


      # ToDo: If we have generic artifact types, then we need to load all generic 
      # artifact types into this array
      artifacttypes = ["re_attachment", "re_goal", "re_processword", 
                       "re_rationale", "re_requirement", "re_scenario", 
                       "re_section", "re_task", "re_user_profile", 
                       "re_use_case", "re_vision", "re_workarea"]
      artifacttypes.each do |artifacttype|
        in_use = 0
        unless artifact_array.blank?
          artifact_array.each do |item|
            if ( item == artifacttype)
              in_use = 1
            end 
          end
        end
        
        ReVisualizationConfig.new(
          :project_id => project_id, 
          :user_id => User.current.id, 
          :visualization_type => visualization_type, 
          :configuration_type => 'artifact',
          :configuration_name => artifacttype,
          :configuration_value => in_use
        ).save
      end

      relationtypes = ReRelationtype.relation_types(project_id)
      relationtypes.each do |relationtype|
        in_use = 0
        unless relation_array.blank?
          relation_array.each do |item|
            if ( item == relationtype)
              in_use = 1
            end 
          end
        end
        
        ReVisualizationConfig.new(
          :project_id => project_id, 
          :user_id => User.current.id, 
          :visualization_type => visualization_type, 
          :configuration_type => 'relation',
          :configuration_name => relationtype,
          :configuration_value => in_use
        ).save
      end
      
   end
   

  def self.get_artifact_filter_as_stringarray(project_id, visualization_type)
    
    config = ReVisualizationConfig.find_all_by_project_id_and_user_id_and_visualization_type_and_configuration_type_and_configuration_value(project_id, User.current.id, visualization_type, "artifact", 1)
    @choosen_artifacts = []
    config.each do |item|
      @choosen_artifacts << item.configuration_name.camelize
    end
    
    return @choosen_artifacts
    
  end
   
  def self.get_relation_filter_as_stringarray(project_id,visualization_type)
    
    config = ReVisualizationConfig.find_all_by_project_id_and_user_id_and_visualization_type_and_configuration_type_and_configuration_value(project_id, User.current.id, visualization_type, "relation", 1)
    @choosen_relation = []
    config.each do |item|
      @choosen_relation << item.configuration_name.camelize
    end
    
    return @choosen_relation
 
  end
  
  def self.get_max_deep(project_id, visualization_type)
    config = ReVisualizationConfig.find_by_project_id_and_user_id_and_visualization_type_and_configuration_name(project_id, User.current.id, visualization_type, "max_deep")
    
    unless config.blank?
      return config.configuration_value.to_i
    else
      return 0
    end
  end
  
  def self.save_max_deep(project_id,max_deep,visualization_type)
    config = ReVisualizationConfig.find_by_project_id_and_user_id_and_visualization_type_and_configuration_name(project_id, User.current.id, visualization_type, "max_deep")
    
    unless config.blank?
      config.configuration_value = max_deep
      config.save
    else
      ReVisualizationConfig.new(
          :project_id => project_id, 
          :user_id => User.current.id, 
          :visualization_type => visualization_type, 
          :configuration_type => 'config',
          :configuration_name => 'max_deep',
          :configuration_value => max_deep
      ).save
    end
  end
  
  def self.get_issue_filter(project_id, visualization_type)
    saved_filter = ReVisualizationConfig.find_by_project_id_and_user_id_and_visualization_type_and_configuration_name(project_id, User.current.id, visualization_type, "issue")
    
    unless saved_filter.blank?
      if saved_filter.configuration_value == 1
        return true
      end
    end
    return false
  end
   
  
  def self.is_filter_set_for_visualization(project_id, visualization_type, artefakt_name)

    visualization = ReVisualizationConfig.find_by_project_id_and_user_id_and_visualization_type_and_configuration_name(project_id, User.current.id, visualization_type, artefakt_name)
    
    unless visualization.blank?
      if visualization.configuration_value == "1"
        return true
      end
    end
    
    return false 
    
  end
   
end