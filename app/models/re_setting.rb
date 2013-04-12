class ReSetting < ActiveRecord::Base
  unloadable

  belongs_to :project
  #validates_uniqueness_of :name, :scope => :project_id
  validates :name , :uniqueness => { :scope => :project_id}

  # Hash used to cache setting values
  @cached_settings = {}
  @cached_cleared_on = Time.now

  def self.get_plain(name, project_id)
    # reads a project specific setting (if available from cache)
    # the setting will be returned in plain text
    name = name.to_s
    v = @cached_settings[name + project_id.to_s]
    v ? v : (@cached_settings[name + project_id.to_s] = load_setting(name, project_id))
  end

  def self.set_plain(name, project_id, v)
    # creates a project specific setting
    # the setting must be plain text
    name = name.to_s
    setting = find_by_name_and_project_id(name, project_id)
    setting ||= new(:name => name, :value => v, :project_id => project_id)
    setting.value = (v ? v : "")
    @cached_settings[name + project_id.to_s] = nil
    logger.debug("saving setting " + setting.name + " for project " + project_id.to_s)
    setting.save
    setting.value
  end
  
  def self.set_serialized(name, project_id, object)
    # reads a project specific setting (if available from cache)
    # the setting will be returned as object
    json_string = ActiveSupport::JSON.encode(object)
    self.set_plain(name, project_id, json_string)
  end
  
  def self.get_serialized(name, project_id)
    # creates a project specific setting
    # the setting should be a (JSON serializable) object (hash, array and so on)
    json_string = self.get_plain(name, project_id)
    ActiveSupport::JSON.decode(json_string) unless json_string.nil?
  end
  
  def self.active_re_artifact_settings(project_id)
    order = ReSetting.get_serialized("artifact_order", project_id)
    generate_active_settings_hash(order, project_id)
  end
  
  def self.active_re_relation_settings(project_id)
    order = ReSetting.get_serialized("relation_order", project_id)
    generate_active_settings_hash(order, project_id)
  end  
  
  def self.check_cache
    # Checks if settings have changed since the values were read
    # and clears the cache hash if it's the case
    # Called once per request as for the redmine settings.
    # Anyway, this is called only within the redmine plugin controllers
    settings_updated_on = Setting.maximum(:updated_on)
    if settings_updated_on && @cached_cleared_on <= settings_updated_on
      @cached_settings.clear
      @cached_cleared_on = Time.now
      logger.info "Settings cache cleared." if logger
    end
  end
  
  def self.force_reconfig
    
    Project.all.each do |p|      
      if (p.enabled_module_names.include? 'requirements')        
        ReSetting.set_serialized("unconfirmed", p.id, true)  
      end
    end 
    
  end

  private

  def self.load_setting(name, project_id)
    setting = find_by_name_and_project_id(name, project_id)
    setting.value unless setting.nil?
  end
  
  def self.generate_active_settings_hash(order, project_id)
    active_settings = {}
    unless order.nil?
      order.each do |s|
        setting = self.get_serialized(s, project_id)
        active_settings[s] = setting if setting["in_use"]
      end
    end
    active_settings
  end
    
end
