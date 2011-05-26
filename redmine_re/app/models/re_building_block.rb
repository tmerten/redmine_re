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
  
  # This method builds a hash containing as keys all building blocks belonging
  # to the type of the artifact properties passed. The value for each key is
  # an array with all bb_data_objects belonging to the artifact properties and the
  # building block being the key. 
  def self.find_all_bbs_and_data(artifact_properties)
    building_blocks = ReBuildingBlock.find_all_by_artifact_type(artifact_properties.artifact_type)
    bb_hash = {}
    for bb in building_blocks do 
      # TODO: Insert all bb_data classes here when they come into existance.
      data_for_bb = []
      ['ReBbDataText'].each do |bb_class|
        data_for_bb += bb_class.constantize.find(:all, :conditions => {:re_bb_text_id => bb.id, :re_artifact_properties_id => artifact_properties.id})
      end
      # Zu Demonstrationszwecken, um den Test fehlschlagen zu lassen:
      # data_for_bb = bb.re_bb_data_texts
      bb_hash[bb] = data_for_bb      
    end
    bb_hash
  end
  
  def self.save_data(artifact_properties_id, data_hash)
    data_hash.keys.each do |bb_id|
      bb = ReBbText.find_by_id(bb_id)
      bb.save_datum(data_hash[bb_id], artifact_properties_id) 
    end
  end
  
end
