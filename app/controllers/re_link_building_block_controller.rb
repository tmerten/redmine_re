class ReLinkBuildingBlockController < RedmineReController
  unloadable
  menu_item :re
  
  @params
  
  def popup 
    @deletediv = "bb_form_"+params[:re_bb_id]+"_"+params[:re_bb_data_id]+"_"+params[:project_id]
    @params = params
    render (:partial => 're_building_block/re_bb_link/remote_edit_link.rhtml')
  end
  
  def popup_close_and_update_link 
    
    bb_data = ReBbDataLink.find_by_id(params[:re_bb_data_id])    
    bb_data.attributes = params[:post]
    bb_data.save
    params[:url] = params[:post][:url]
    params[:description] = params[:post][:description]
    
    @params = params
    
    render (:partial => 're_building_block/re_bb_link/remote_edit_link_finished.rhtml')
  end
end