class ReBuildingBlock < ActiveRecord::Base
  unloadable
  
  validates_presence_of :name
  before_save :prohibit_save_of_new_artifact_type
  
  def prohibit_save_of_new_artifact_type
    # Check if BuildingBlock was saved before
    unless self.id.nil?
      original = ReBuildingBlock.find(self.id)
      # check if artifact_type was saved before
      unless original.artifact_type.nil?
       self.artifact_type = original.artifact_type 
      end
    end
  end
  
  
end
