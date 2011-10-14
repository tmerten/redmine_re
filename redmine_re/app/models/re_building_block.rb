class ReBuildingBlock < ActiveRecord::Base
  unloadable
      
  include StrategyProcs
  
  belongs_to :project
  
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
    building_blocks = ReBuildingBlock.find(:all, :conditions => {:artifact_type => artifact_properties.artifact_type}, :order => :position)
    bb_hash = ActiveSupport::OrderedHash.new
    for bb in building_blocks do 
      bb_hash[bb] = bb.find_my_data(artifact_properties)
    end
    bb_hash
  end
  
  # This method delivers an array with all bb that belong to a given 
  # artifact type like "ReGoal".
  def self.find_bbs_of_artifact_type(artifact_type)
    ReBuildingBlock.find(:all, :conditions => {:artifact_type => artifact_type}, :order => :position)
  end
  
  # This method delivers an array with all data objects for 
  # the building block from which it is called, reducing the 
  # result to data for on special artifact
  def find_my_data(artifact_properties)
    building_block_reference_column_name = (self.class.to_s.underscore + '_id').to_sym
    bb_data_class = self.get_data_class_name
    data_for_bb = bb_data_class.constantize.find(:all, :conditions => {building_block_reference_column_name => self.id, :re_artifact_properties_id => artifact_properties.id}) 
    return data_for_bb
  end
  
  # This method delegates the saving of the builing block data
  # sent by an artifact form to every building block used by that
  # artifact.
  def self.save_data(artifact_properties_id, data_hash)
    unless data_hash.nil?
      data_hash.keys.each do |bb_id|
        bb = ReBuildingBlock.find_by_id(bb_id)
        bb.save_datum(data_hash[bb_id], artifact_properties_id) 
      end
    end
  end
  
  # This method performs an easy string operation to
  # build the data class name from the type of the building block 
  def get_data_class_name
    self.class.to_s.gsub('ReBb', 'ReBbData')
  end
  
  # This method can be called to validate the custom fields of an artifact.
  # Therefore the artifact properties of the artifact have to be transmitted.
  def self.validate_building_blocks(re_artifact_properties, bb_error_hash)
    bb_hash = self.find_all_bbs_and_data(re_artifact_properties)
    unless bb_hash.nil?
      bb_hash.keys.each do |bb|
        validation_strategy_hash = bb.validation_strategies
        unless bb_hash[bb].nil?
          unless validation_strategy_hash.empty?
            validation_strategy_hash.keys.each do |validation_strategy|
              bb_hash[bb].each do |datum|
                bb_error_hash = validation_strategy.call(bb, datum, bb_error_hash, validation_strategy_hash[validation_strategy])    
              end
            end
          end  
        end
        # Validation concerning the whole Building Block and all its data 
        validation_whole_data_strategy_hash = bb.validation_whole_data_strategies
        validation_whole_data_strategy_hash.keys.each do |validation_strategy|
          bb_error_hash = validation_strategy.call(bb, bb_hash[bb], bb_error_hash, validation_whole_data_strategy_hash[validation_strategy]) 
        end
      end
    end
    bb_error_hash
  end
  
  
  # This method can be called to do different additional work before saving of 
  # the building_block. The buildingblock is transmitted and delivered back by
  # each strategy.
  def self.do_additional_work_before_save(re_bb, params)
    additional_work_strategy_hash = re_bb.additional_work_before_save_strategies
    unless additional_work_strategy_hash.empty?
      additional_work_strategy_hash.keys.each do |additional_work_strategy|
        re_bb = additional_work_strategy.call(re_bb, params, additional_work_strategy_hash[additional_work_strategy])    
      end 
    end    
    re_bb
  end
  
  
  # This method can be called to do different additional work after saving of 
  # the building_block. 
  def self.do_additional_work_after_save(re_bb, params)
    additional_work_strategy_hash = re_bb.additional_work_after_save_strategies
    unless additional_work_strategy_hash.empty?
      additional_work_strategy_hash.keys.each do |additional_work_strategy|
        re_bb = additional_work_strategy.call(re_bb, params, additional_work_strategy_hash[additional_work_strategy])    
      end 
    end    
    re_bb
  end
  
  
  
end
