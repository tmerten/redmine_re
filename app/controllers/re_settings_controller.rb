class ReSettingsController < RedmineReController
  unloadable
  menu_item :re

  def configure
    initialize_artifact_order(@project.id)
    initialize_relation_order(@project.id)

     name = @project.name      
     if name.length < 3 
      name = name+" Project" 
     end
     if name.length > 50
      name = name[0..49]
     end 
     
    @project_artifact = ReArtifactProperties.where({
      :project_id => @project.id,
      :artifact_type => "Project"}
    ).first_or_create!({
      :created_by => User.current.id,
      :updated_by => User.current.id,
      :artifact_id => @project.id,     
      :description => @project.description,
      :name => name}
    )
    
    @plugin_description = ReSetting.get_plain("plugin_description", @project.id)

    if request.post?
      save_user_config
    elsif params[:firstload] == "1"
      flash.now[:notice] = t(:re_settings_have_to_save)
    end

    # checking all artifacts should be done every time for now
    # since we are still adding new stuff which otherwise does
    # not get configured appropriately
    # Anyway, it does not take much time and its done only in here
    @re_artifact_configs = {}
    @re_artifact_order.each do |artifact_type|
      configured_artifact = ReSetting.get_serialized(artifact_type, @project.id)
      if configured_artifact.nil?
        logger.debug("##### found an unconfigured artifact of type '" + artifact_type.to_s + "', creating an initial configuration")
        configured_artifact = {}
        configured_artifact['in_use'] = true
        configured_artifact['alias'] = artifact_type.gsub(/^re_/, '').humanize
        configured_artifact['color'] = artifact_type.to_s.classify.constantize::INITIAL_COLOR #"%06x" % (rand * 0xffffff)
                
        ReSetting.set_serialized(artifact_type, @project.id, configured_artifact)
      end
      @re_artifact_configs[artifact_type] = configured_artifact
    end

    @re_relation_configs = {}
    @re_relation_order.each do |relation_type|
      configured_relation = ReSetting.get_serialized(relation_type, @project.id)
      if configured_relation.nil?
        logger.debug("##### found an unconfigured relation of type '" + relation_type.to_s + "', creating an initial configuration")
        configured_relation = {}
        configured_relation['in_use'] = true
        configured_relation['alias'] = relation_type.humanize
        
        configured_relation['color'] = ReArtifactRelationship::INITIAL_COLORS[ReArtifactRelationship::ALL_RELATION_TYPES.index(relation_type)]
        configured_relation['show_in_visualization'] = true
        ReSetting.set_serialized(relation_type, @project.id, configured_relation)
      end
      @re_relation_configs[relation_type] = configured_relation
    end

    @re_settings = {}
    @re_settings["visualization_size"] = ReSetting.get_plain("visualization_size", @project.id)
    @re_settings["visualization_size"] ||= 800

    @export_formats = get_available_export_formats
    @current_export_format = ReSetting.get_plain("export_format", @project.id)   
  end

  def configure_fields
    @building_blocks = ReBuildingBlock.find_bbs_of_artifact_type(params[:artifact_type].camelcase, @project.id)
    @artifact_type = params[:artifact_type]
    @re_userdefined_fields_order = @building_blocks.map {|bb| 're_bb_' + bb.id.to_s}

    if request.post?
      @re_userdefined_fields_order = ActiveSupport::JSON.decode(params[:re_userdefined_fields_order])
      @re_userdefined_fields_order.each_with_index do |id_string, i|
        id = id_string.gsub('re_bb_', '').to_i
        re_bb = ReBuildingBlock.find(id)
        re_bb.mandatory = params[:re_artifact_configs][:bb][id.to_s][:mandatory].nil? ? false : true 
        re_bb.for_condensed_view = params[:re_artifact_configs][:bb][id.to_s][:for_condensed_view].nil? ? false : true 
        # Save new position of the building block
        position_object = ReBbProjectPosition.find(:first, :conditions => {:re_building_block_id => id, :project_id => @project.id}) || ReBbProjectPosition.new(:re_building_block_id => id, :project_id => @project.id)
        position_object.position = i
        position_object.save
        # Test if for_every_project is changed from true to false. If so, delete the objects of class
        # ReBbProjectPositions which are of no use any longer. Otherwise save the new position.
        if params[:re_artifact_configs][:bb][id.to_s][:for_every_project].nil? and re_bb.for_every_project
          position_objects = ReBbProjectPosition.find(:all, :conditions => {:re_building_block_id => re_bb.id})  
          position_objects.each {|obj| obj.delete unless obj.project_id == re_bb.project_id}
        end
        re_bb.for_every_project = params[:re_artifact_configs][:bb][id.to_s][:for_every_project].nil? ? false : true 
        re_bb.for_search = params[:re_artifact_configs][:bb][id.to_s][:for_search].nil? ? false : true 
        re_bb.multiple_values = params[:re_artifact_configs][:bb][id.to_s][:multiple_values].nil? ? false : true 
        re_bb.save     
      end
      @building_blocks = ReBuildingBlock.find_bbs_of_artifact_type(params[:artifact_type].camelcase, @project.id)
    end
  end

  def self.for(artifact_type, project_id)
    # returns the settings hash for the according artifact_type
    self.get_serialized(artifact_type, project_id)
  end
  
  def edit_artifact_type_description
    @artifact_type = params[:artifact_type]
    configured_artifact = ReSetting.get_serialized(@artifact_type, @project.id)
    @description = configured_artifact['description']
    # Needed to use the form for helper and fill the textfield properly
    if request.post?
      configured_artifact['description'] = params[:description] unless params[:description].nil? 
      ReSetting.set_serialized(@artifact_type, @project.id, configured_artifact)
      flash.now[:notice] = l(:re_description_updated_successfully)
      @description = configured_artifact['description']
    end
    
  end

private

  def initialize_artifact_order(project_id)
    configured_artifact_types = Array.new
    stored_settings = ReSetting.get_serialized("artifact_order", project_id)
    configured_artifact_types.concat(stored_settings) if stored_settings

    all_artifact_types = Dir["#{Rails.root}/plugins/redmine_re/app/models/re_*.rb"].map do |f|
      fd = File.open(f, 'r')
      File.basename(f, '.rb') if fd.read.include? "acts_as_re_artifact"
    end

    all_artifact_types.delete_if { |x| x.nil? }
    all_artifact_types.delete(:ReArtifactProperties)
    all_artifact_types.delete(:ReArtifactsConfig)
    all_artifact_types.delete_if { |v| configured_artifact_types.include? v }
    configured_artifact_types.concat(all_artifact_types)

    ReSetting.set_serialized("artifact_order", project_id, configured_artifact_types)
    @re_artifact_order = configured_artifact_types
  end

  def initialize_relation_order(project_id)
    configured_relation_types = Array.new
    stored_settings = ReSetting.get_serialized("relation_order", project_id)
    configured_relation_types.concat(stored_settings) if stored_settings

    all_relation_types = []
    ReArtifactRelationship::RELATION_TYPES.values.each { |k| all_relation_types << k.to_s }
    ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.each { |k| all_relation_types << k.to_s }

    all_relation_types.delete_if { |v| configured_relation_types.include? v }
    configured_relation_types.concat(all_relation_types)

    @re_relation_order = configured_relation_types
  end

  def save_user_config
    #store new settings and configurations
    new_settings = params[:re_settings]
    new_artifact_order = ActiveSupport::JSON.decode(params[:re_artifact_order])
    new_relation_order = ActiveSupport::JSON.decode(params[:re_relation_order])

    ReSetting.set_plain("relation_management_pane", @project.id, new_settings.has_key?("relation_management_pane").to_s)
    ReSetting.set_plain("visualization_size", @project.id, new_settings["visualization_size"])
    ReSetting.set_plain("plugin_description", @project.id, params["plugin_description"])
    @plugin_description = params["plugin_description"]

    ReSetting.set_serialized("artifact_order", @project.id, new_artifact_order)
    ReSetting.set_serialized("relation_order", @project.id, new_relation_order)

    new_artifact_configs = params[:re_artifact_configs]
    new_artifact_configs.each_pair do |k,v|
      # disabled checkboxes do not send a key/value pair
      v['in_use'] = v.has_key? 'in_use'
      v['printable'] = v.has_key? 'printable'
      logger.debug('storing:' + k + ' ' + @project.id.to_s + ' ' + v.to_yaml)
      ReSetting.set_serialized(k, @project.id, v)
    end

    new_relation_configs = params[:re_relation_configs]
    new_relation_configs.each_pair do |k, v|
      v['in_use'] = v.has_key? 'in_use'
      v['show_in_visualization'] = v.has_key? 'show_in_visualization'
      ReSetting.set_serialized(k, @project.id, v)
    end

    @re_artifact_order = ReSetting.get_serialized("artifact_order", @project.id)
    @re_relation_order = ReSetting.get_serialized("relation_order", @project.id)      
    ReSetting.set_serialized("unconfirmed", @project.id, false)
      
      
    if params["export_format"].blank?
      ReSetting.set_plain("export_format", @project.id, "disabled")
    else
      ReSetting.set_plain("export_format", @project.id, params["export_format"])
    end
    
    flash[:notice] = t(:re_configs_saved)
    
    redirect_to :controller => "requirements", :action => "index", :project_id => @project.id  


  end

  def get_available_export_formats 
    #Parse available output formats from pandoc helpfile    
    formats = `pandoc --help`
    outputformatarray = []
    if formats.nil?
      flash[:error] = t(:re_export_error)
    else
      start = formats.index("Output formats: ")      
      start = start + 16 unless start.nil? 
      ende =  formats.index("Options:")
      ende = ende - 2 unless ende.nil?        
      outputformats = ""
      outputformats = formats[start..ende] unless ende.nil?     
      outputformats = outputformats.squish    
      outputformatarray = outputformats.split(', ')         
    end
    return outputformatarray
  end
  
  
end
