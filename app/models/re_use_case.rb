class ReUseCase < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#0000ff"
  
  acts_as_re_artifact

  has_many :re_use_case_steps, :inverse_of => :re_use_case, :dependent => :destroy, :order => :position

  accepts_nested_attributes_for :re_use_case_steps, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['description'].blank? && attributes['step_type'].blank? }
    

  def create_hook(params)
    logger.debug("************************************* working?")
    
    if params
      primary_id = params[:primary_actor_id]
      params[:secondary_actors_ids]
    end 
    #relation_to_primary_actor = ReArtifactRelationship.new()
    logger.debug "****************************** #{self.re_artifact_properties.inspect}"
  end


end
