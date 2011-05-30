class ReBuildingBlockController < RedmineReController
  unloadable
  menu_item :re

  def new
    redirect_to :action => 'edit', :project_id => params[:project_id], :artifact_type => params[:artifact_type]
  end
  
  def edit
   @re_building_block = ReBuildingBlock.find_by_id(params[:id]) || ReBuildingBlock.new
   @project = Project.find_by_id(params[:project_id])
   @artifact_type = params[:artifact_type]
   
   if request.post?
      params[:re_building_block][:artifact_type] = params[:artifact_type]
      params[:re_building_block][:type] = params[:type]
      # Test if @re_builing_block is a new object
      @re_building_block = params[:type].constantize.new if @re_building_block.artifact_type.nil?
      @re_building_block.attributes = params[:re_building_block]
      flash[:notice] = t(:re_bb_saved) if save_ok = @re_building_block.save
      # the following if statement is only needed in a rough way of building
      # a selection bb. It will be replaced with a better way of handling things during refactory.
      if params[:type] == 'ReBbSelection'
        options = params[:options].split(%r{,\s*})
        options = options.delete_if {|x| x == "" }
        options << @re_building_block.default_value unless options.include? @re_building_block.default_value
        existing_options = ReBbOptionSelection.find_all_by_re_bb_selection_id(@re_building_block.id).map {|x| x.value.to_s}
        options -= existing_options
        options.each do |option|
          ReBbOptionSelection.new(:value => option, :re_bb_selection_id => @re_building_block.id).save
        end
      end      
      redirect_to :action => 'edit', :id => @re_building_block.id, :project_id => @project.id and return if save_ok
   end
  end

end
