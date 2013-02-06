class ReUseCase < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#0000ff"
  
  acts_as_re_artifact

  has_many :re_use_case_steps, :inverse_of => :re_use_case, :dependent => :destroy, :order => :position

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
  
  private

  def update_primary_actor(actor_id, source_id)
       
       
       if actor_id.to_i == -1
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
