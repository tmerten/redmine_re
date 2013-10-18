class ReUseCase < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#0000ff"
  
  acts_as_re_artifact

  has_many :re_use_case_steps, :inverse_of => :re_use_case, :dependent => :destroy, :order => :position

  has_one :primary_actor_relation, 
    :source => :relationships_as_source,
    :through => :re_artifact_properties, 
    :class_name => "ReArtifactRelationship", 
    :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pac]]


  has_one :primary_actor, 
    :through => :primary_actor_relation, 
    :class_name => "ReArtifactProperties",  
    :source => "sink"


  has_many :actor_relations, 
    :source => :relationships_as_source,
    :through => :re_artifact_properties, 
    :class_name => "ReArtifactRelationship", 
    :conditions => ["re_artifact_relationships.relation_type = ?", ReArtifactRelationship::SYSTEM_RELATION_TYPES[:ac]]

  has_many :actors, 
    :through => :actor_relations, 
    :class_name => "ReArtifactProperties",  
    :source => "sink"


  accepts_nested_attributes_for :re_use_case_steps, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['description'].blank? && attributes['step_type'].blank? }
    

  def create_hook(params)
    
    if params
      unless params['secondary_actor_ids'].blank? && params['id'].blank?                      
        update_secondary_actor(params['secondary_actor_ids'], params['id'])  
      end

      unless params['primary_user_profile'].blank? && params['id'].blank?                      
        update_primary_actor(params['primary_user_profile'], params['id'])  
      end

    end 
  end

  def new_hook(params)
    
  end

  def edit_hook(params)
    
  end


  def specific_attributes_as_string
    
    myattributes = ""
  
    goal_levels = {
    5 => I18n.t(:re_use_case_abstract_overview),
    4 => I18n.t(:re_use_case_overview),
    3 => I18n.t(:re_use_case_user_goal),
    2 => I18n.t(:re_use_case_function),
    1 => I18n.t(:re_use_case_low)}
    
    myattributes << "h3. #{I18n.t(:re_use_case_specific_attributes)} \n \n"
    myattributes << "*#{I18n.t(:re_use_case_level)}* #{goal_levels[self.goal_level]}  \n \n"
    
    myattributes << "*#{I18n.t(:re_use_case_trigger)}* #{self.trigger}  \n \n" unless self.trigger.blank?
    myattributes << "*#{I18n.t(:re_use_case_precondition)}* #{self.precondition}  \n \n" unless self.precondition.blank?      
    myattributes << "*#{I18n.t(:re_use_case_postcondition)}* #{self.precondition}  \n \n" unless self.postcondition.blank?  
    myattributes << "*#{I18n.t(:re_use_case_primary_actor)}* #{self.primary_actor.name}  \n \n" unless self.primary_actor.blank?
      
    #secondary actors    
    if !self.actors.blank?      
      myattributes << "*Secondary Actors* #{self.actors.first.name}"
      self.actors.each do |secondary|        
        myattributes << ", #{secondary.name}" unless secondary == self.actors.first
      end
      myattributes << " \n\n"
    end
        
    #use case steps as table needs pandoc >= 1.11     
    if !self.re_use_case_steps.blank?
      myattributes << "*#{I18n.t(:re_use_case_steps)}* \n\n"    
      myattributes << "| | *#{I18n.t(:re_user_steps)}* |  *#{I18n.t(:re_system_steps)}* | \n\n"
      
      counter_steps = 1
      self.re_use_case_steps.each do |current_re_use_case_step|            
        #user steps  
        if current_re_use_case_step.step_type == 1
          myattributes << "| #{counter_steps} | #{current_re_use_case_step.description} | | \n\n"        
        #system steps
        elsif current_re_use_case_step.step_type == 2
          myattributes << "| #{counter_steps} | | #{current_re_use_case_step.description} | \n\n"
        end      
        counter_steps = counter_steps + 1;              
      end #each                
    end #if blank
    
    #expansions
    myattributes << "*#{I18n.t(:re_use_case_expansions)}* \n\n" unless self.re_use_case_steps.blank?
    counter_steps = 1      
    self.re_use_case_steps.each do |current_re_use_case_step| 
      counter_expansions = 1 
      unless current_re_use_case_step.re_use_case_step_expansions.blank? 
        current_re_use_case_step.re_use_case_step_expansions.each do |current_re_use_case_step_expansion|
          myattributes << "#{counter_steps}.#{counter_expansions} #{I18n.t( current_re_use_case_step_expansion.expansion_type_translation_key)} #{current_re_use_case_step_expansion.description} \n\n"  
          counter_expansions = counter_expansions + 1
       end #each expansion        
       counter_steps = counter_steps + 1
      end #unless
    end #each step      
    
    return myattributes
  end 

 def self.getAllUserProfiles project_id
   user_profiles = ReArtifactProperties.find_all_by_artifact_type_and_project_id('ReUserProfile', project_id)    
 end  
  
    
  private

  def update_primary_actor(actor_id, source_id)
       
       if actor_id.blank?
        delete_actor = ReArtifactRelationship.destroy_all(:source_id => source_id, :relation_type => ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pac])
        return 
       end
       
       test_if_exsists = ReArtifactRelationship.where(:source_id => source_id, :relation_type => ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pac]).first
       
       if !test_if_exsists.nil?
        test_if_exsists.sink_id = actor_id
        test_if_exsists.save
       
       else
         
        new_relation = ReArtifactRelationship.new(:sink_id => actor_id, :source_id => source_id, :relation_type => ReArtifactRelationship::SYSTEM_RELATION_TYPES[:pac], :position => 1)
        if !new_relation.save
            logger.debug("Error:#{new_relation.errors.inspect}")
        end          
       end
       
     
  end
  
  def update_secondary_actor(actors, source_id)
    pos = 1
    
    #if there are no secondary actory set, init empty array
    if actors.nil?
      actors = []
    end
    actors = actors.collect{|i| i.to_i}

    #get all current secondary actors ids
    old_secondary_actor_ids = get_all_secondary_actors_ids(source_id)    
    #calculate secondary actors to delete
    to_delete_secondary_actor_ids = old_secondary_actor_ids - actors    
    #calculate new secondary actors
    to_add_secondary_actor_ids = actors - old_secondary_actor_ids

    #delete
    to_delete_secondary_actor_ids.each do |delete_actor_id|
      delete_actor = ReArtifactRelationship.destroy_all(:sink_id => delete_actor_id, :source_id => source_id, :relation_type => ReArtifactRelationship::SYSTEM_RELATION_TYPES[:ac])
    end
    
    #add new secondary actors
    to_add_secondary_actor_ids.each do |actor_id| 
            
      new_relation = ReArtifactRelationship.new(:sink_id => actor_id, :source_id => source_id, :relation_type => ReArtifactRelationship::SYSTEM_RELATION_TYPES[:ac], :position => pos)
      if !new_relation.save
          logger.debug("Error:#{new_relation.errors.inspect}")
      end       
      pos = pos + 1    

    end
     
  end
  
  #function returns all sink_ids as array of all related secondary actors to an given sink_id 
  def get_all_secondary_actors_ids(source_id)
      secondary_actor = ReArtifactRelationship.where(:source_id => source_id, :relation_type => ReArtifactRelationship::SYSTEM_RELATION_TYPES[:ac])      
    
      actors = []
      
      secondary_actor.each do |actor|
        actors << actor[:sink_id]
      end
      
      return actors
  end 
 

end