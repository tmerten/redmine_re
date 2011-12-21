class ReBuildingBlockController < RedmineReController
  unloadable
  menu_item :re
  
  
  ##### Normal CRUD-Operations on the building blocks itself #####
  
  def new
    redirect_to :action => 'edit', :project_id => params[:project_id], :artifact_type => params[:artifact_type]
  end
  
  def delete
    ReBuildingBlock.find(params[:id]).destroy
    redirect_to :controller => :re_settings, :action => 'configure_fields', :project_id => params[:project_id], :artifact_type => params[:artifact_type]  
  end
  
  def edit
   @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
   @project = Project.find(params[:project_id])
   @artifact_type = params[:artifact_type]
   # Check for ArtifactSelectionBuildingBlock if one selected artifact is choosen already
   if ! @re_building_block.referred_artifact_types.nil? and @re_building_block.referred_artifact_types.count == 1
     @artifact_selected = @re_building_block.referred_artifact_types.first.camelcase
   else
     @artifact_selected = nil
   end
   if request.post?
      params[:re_building_block][:artifact_type] = params[:artifact_type]
      # Test if @re_builing_block is a new object
      @re_building_block = params[:type].constantize.new if @re_building_block.artifact_type.nil?
      @re_building_block.attributes = params[:re_building_block]
      @re_building_block.project_id = @project.id if @re_building_block.new_record?
      # Calling the strategies for handling additional work before normal saving
      @re_building_block = ReBuildingBlock.do_additional_work_before_save(@re_building_block, params)
      flash[:notice] = t(:re_bb_saved) if save_ok = @re_building_block.save
      # Calling the strategies for handling additional work after normal saving
      ReBuildingBlock.do_additional_work_after_save(@re_building_block, params)
      redirect_to :action => 'edit', :id => @re_building_block.id, :building_block => @re_building_block, :building_block_type => params[:type].underscore, :artifact_type => params[:artifact_type], :project_id => @project.id and return if save_ok
   end
 end
 
 
 ##### Methods to deal with data objects linked to building blocks #####
 
 # This method is called as a reaction to the clicking on the dustbin-icons
 # beside the datum in a multiple data representation of a building block
 def delete_data
   bb = ReBuildingBlock.find(params[:re_bb_id])
   datum = bb.get_data_class_name.constantize.find(params[:re_bb_data_id])
   @artifact = ReArtifactProperties.find(datum.re_artifact_properties_id)
   @artifact_type = @artifact.artifact_type   
   datum.delete unless datum.nil?
   bb_error_hash = {} 
   bb_error_hash = ReBuildingBlock.validate_building_blocks(@artifact, bb_error_hash, @project.id)
   data = bb.find_my_data(@artifact)
   if data.count <= 1 and ! bb.multiple_values
     partial = bb.data_form_partial_strategy
   else
     partial = bb.multiple_data_form_partial_strategy
   end
   render :partial => partial, :locals => {:re_bb => bb, :data => data, :bb_error_hash => bb_error_hash}
 end


  ##### Methods to react to observe fields via updating parts of the gui #####
  
  def update_config_form
    @artifact_type = params[:artifact_type]
    @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
    # renders the rjs-Template with the same name
  end
  
  def react_to_change_in_field_multiple_values
    @artifact_type = params[:artifact_type]
    @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
    # renders the rjs-Template with the same name
  end
  
  def react_to_change_in_field_referred_artifact_types
    @artifact_type = params[:artifact_type]
    @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
    # renders the rjs-Template with the same name
  end
  
  def react_to_change_in_data_field_artifact_type
    artifact_type = params[:artifact_type]
    @artifact = artifact_type.camelcase.constantize.find_by_id(params[:id], :include => :re_artifact_properties) || artifact_type.camelcase.constantize.new
    @artifact_type = artifact_type
    @re_bb = ReBuildingBlock.find(params[:re_bb_id]) 
    # renders the rjs-Template with the same name
  end
  
  def react_to_change_in_fields_minimal_maximal_numbers
    @artifact_type = params[:artifact_type]
    @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
    # renders the rjs-Template with the same name 
  end

end
