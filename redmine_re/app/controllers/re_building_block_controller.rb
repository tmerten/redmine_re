class ReBuildingBlockController < RedmineReController
  unloadable
  menu_item :re

  def new
    redirect_to :action => 'edit', :project_id => params[:project_id], :artifact_type => params[:artifact_type]
  end
  
  def edit
   @artifact_type = params[:artifact_type]
   @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
   @project = Project.find_by_id(params[:project_id])
   
   if request.post?
      params[:re_building_block][:artifact_type] = @artifact_type if @re_building_block.artifact_type.nil? 
      @re_building_block.attributes = params[:re_building_block]
      
      flash[:notice] = t(:re_bb_saved) if save_ok = @re_building_block.save
      
      redirect_to :action => 'edit', :id => @re_building_block.id, :project_id => @project.id and return if save_ok
   end
  end



end
