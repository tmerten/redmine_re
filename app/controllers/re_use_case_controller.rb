class ReUseCaseController < RedmineReController
  unloadable
  menu_item :re

  # The new and edit functions will be called via the RedmineReController.
  # Both methods are pretty much equal for every artifact type (goal, scenario
  # etc. ).
  #
  # If your artifact type needs special treatment uncommenct the following
  # hook method(s).
  # You find an example of how to use these hooks in the ReTaskController
  
  def new_hook(params)
    @artifact.goal_level=3
    # Initialize user_profiles for use_case artifact
    @user_profiles = []
    @user_profiles = "re_user_profile".camelcase.constantize.all
    @user_profiles.each { |user_profile| user_profile.re_artifact_properties }
  end

  def edit_hook_after_artifact_initialized(params)
    
    # Initialize user_profiles for use_case artifact
    @user_profiles = []
    @user_profiles = "re_user_profile".camelcase.constantize.all
    @user_profiles.each { |user_profile| user_profile.re_artifact_properties }
    
    # Re Use Case Expansions need to be saved heer, because
    # Rails 2 has an Internal server error with nested forms of depth 2
    unless params[:re_use_case_step_expansions].blank?
      
      params[:re_use_case_step_expansions].each do |expansion|
        
        current_use_case_step_id = 0
        
        expansion.each do |expansion_conts|
          if (expansion_conts.length == 1 )
            logger.debug("Working at Use_case_step_ID: "+expansion_conts.to_s+"\n")
            current_use_case_step_id = expansion_conts.to_s.to_i
            
            # Delete current use case step expansions
            expansions = ReUseCaseStepExpansion.destroy_all(:re_use_case_step_id => current_use_case_step_id)

          else 
            expansion_conts.each do |expansion_conts_depth_2|
              
              current_re_use_case_step_expansion_id = 0
              expansion_conts_depth_2.each do |expansion_conts_depth_3|
                if ( expansion_conts_depth_3.is_a? String )
                  current_re_use_case_step_expansion_id = expansion_conts_depth_3.to_s.to_i
                  logger.debug("Working at Use_case_step_expansion_ID: "+current_re_use_case_step_expansion_id.to_s+"\n")
                else
                  logger.debug(expansion_conts_depth_3.to_json)
                  n = ReUseCaseStepExpansion.new
                  n.re_use_case_step_id = expansion_conts_depth_3[0][:use_case_step_id]
                  n.description         = expansion_conts_depth_3[0][:description]
                  n.position            = expansion_conts_depth_3[0][:position]
                  n.re_expansion_type   = expansion_conts_depth_3[0][:re_expansion_type]
                  n.save 
                end
              end
            end
          end
        end

        # Structure to read
        #["9",
        #  {"1001393":                      # If lenght = 7 => is a random numer | if lenght < 7 => is current_re_use_case_step_expansion_id
        #    [{"description":"Testest",
        #      "use_case_step_id":"9",
        #      "position":"",
        #      "re_expansion_type":"1"
        #    }],
        #   "1005455":                      #
        #     [{"description":"wwwwwww",    #
        #       "use_case_step_id":"9",     # This is
        #       "position":"",              # expansion_conts_depth_2
        #      "re_expansion_type":"1"      #
        #     }]                            #
        #       
        #   }
        #   "10",
        #  {"1001393":
        #    [{"description":"Testest",     #
        #      "use_case_step_id":"9",      # This is
        #      "position":"",               # expansion_conts_deph_3
        #      "re_expansion_type":"1"      #
        #    }],
        #   "1005455":
        #     [{"description":"wwwwwww",
        #       "use_case_step_id":"9",
        #       "position":"",
        #      "re_expansion_type":"1"
        #     }]
        #       
        #   }
        # ]

      end
      
    end
    
    #params[:artifact][:re_use_case_step_expansions] = nil

  end

  #def edit_hook_validate_before_save(params, artifact_valid)
    # must return true, if the validation passed or false if invalid 
    # you should also attach your errors to the @artifact variable

  #  return true
  #end

  def edit_hook_valid_artifact_after_save params
    unless @artifact.re_use_case_steps.empty?
      @artifact.reload.re_use_case_steps
      flash.now[:notice] = t(:re_use_case_and_steps_saved)
    end

      current_relation = ReArtifactRelationship.find_by_source_id_and_relation_type(@artifact.artifact_properties.id, ReArtifactRelationship::RELATION_TYPES[:pof])
      
    if current_relation.blank?
      if ( !params[:primary_user_profile].blank? )
        @new_relation = ReArtifactRelationship.new(:source_id => @artifact.artifact_properties.id, :sink_id => params[:primary_user_profile], :relation_type => ReArtifactRelationship::RELATION_TYPES[:pof])
        @new_relation.save
      end
    else
      current_relation.sink_id = params[:primary_user_profile]
      current_relation.save
    end

    
    unless params[:secondary_user_profile_id].blank?
      params[:secondary_user_profile_id].each do |iid|
        @new_relation = ReArtifactRelationship.new(:source_id => @artifact.artifact_properties.id, :sink_id => iid, :relation_type => ReArtifactRelationship::RELATION_TYPES[:dep])
        @new_relation.save
      end
    end
    @current_primary_user = ReArtifactRelationship.find_by_source_id_and_relation_type(@artifact.artifact_properties.id, ReArtifactRelationship::RELATION_TYPES[:pof])
    
    logger.debug(@artifact.to_yaml)
  end

  #def edit_hook_invalid_artifact_cleanup(params)
  #end

  def autocomplete_sink
    
    @artifact = ReArtifactProperties.find(params[:id]) unless params[:id].blank?

    query = '%' + params[:user_profile_subject].gsub('%', '\%').gsub('_', '\_').downcase + '%'
    @sinks = ReArtifactProperties.find(:all, :conditions => ['lower(name) like ? AND project_id = ? AND artifact_type = ?', query.downcase, @project.id, "ReUserProfile"])

    if @artifact
      @sinks.delete_if{ |p| p == @artifact }
    end

    list = '<ul>'
    for sink in @sinks
      list << render_autocomplete_artifact_list_entry(sink)
    end
    list << '</ul>'
    render :text => list
  end

end
