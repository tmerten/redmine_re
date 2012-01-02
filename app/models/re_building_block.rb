class ReBuildingBlock < ActiveRecord::Base
  unloadable
      
  include StrategyProcs
  
  belongs_to :project
  has_many :re_bb_project_positions, :dependent => :destroy 
  
  validates_presence_of :name
  before_save :prohibit_save_of_new_artifact_type
  before_destroy :delete_occurances_of_bb_from_some_attributes_representation


  ##### Methods to build data arrays or hashes of building blocks and data ##### 
  
  # This method builds a hash containing as keys all building blocks belonging
  # to the type of the artifact properties passed. The value for each key is
  # an array with all bb_data_objects belonging to the artifact properties and the
  # building block being the key. 
  def self.find_all_bbs_and_data(artifact_properties, project_id)
    building_blocks = ReBuildingBlock.find_bbs_of_artifact_type(artifact_properties.artifact_type, project_id)
    bb_hash = ActiveSupport::OrderedHash.new
    for bb in building_blocks do 
      bb_hash[bb] = bb.find_my_data(artifact_properties)
    end
    bb_hash
  end
  
  # This method delivers an array with all bb that belong to a given 
  # artifact type like "ReGoal".
  # Check if position in table re_building_blocks is needed at all!!!
  def self.find_bbs_of_artifact_type(artifact_type, project_id)
    building_blocks = ReBuildingBlock.find(:all, :conditions => {:artifact_type => artifact_type, :project_id => project_id})
    # | means "Set Union" here: Returns a new array by joining this array with other_ary, removing duplicates.
    building_blocks = building_blocks | ReBuildingBlock.find(:all, :conditions => {:artifact_type => artifact_type, :for_every_project => true})
    # The block of sort_by defines the parameter with which the elements are sorted
    building_blocks.sort_by do |bb|
      pos_obj = ReBbProjectPosition.find(:first, :conditions => {:project_id => project_id, :re_building_block_id => bb.id})
      # if there is a pos_obj, return pos_obj.position.If there is no pos_obj 
      # or position is empty, return a high number to arrange the element at 
      # the end of the sorted array.  
      pos_obj && pos_obj.position || building_blocks.length
    end
  end
  
  # This method delivers an array with all data objects for 
  # the building block from which it is called, reducing the 
  # result to data for one special artifact
  def find_my_data(artifact_properties)
    building_block_reference_column_name = (self.class.to_s.underscore + '_id').to_sym
    bb_data_class = self.get_data_class_name
    data_for_bb = bb_data_class.constantize.find(:all, :conditions => {building_block_reference_column_name => self.id, :re_artifact_properties_id => artifact_properties.id}) 
    return data_for_bb
  end
  
  
  ##### Methods to validate and save all bb for one artifact at once #####
  

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
   
  # This method can be called to validate the custom fields of an artifact.
  # Therefore the artifact properties of the artifact have to be transmitted.
  # The error hash has to be transmitted as well. It will be changed if needed
  # and delivered back by the method.
  def self.validate_building_blocks(re_artifact_properties, bb_error_hash, project_id)      
    bb_hash = self.find_all_bbs_and_data(re_artifact_properties, project_id) 
    unless bb_hash.nil?
      bb_hash.keys.each do |bb|
        validation_strategy_hash = bb.validation_strategies
        unless bb_hash[bb].nil?
          unless validation_strategy_hash.empty?
            validation_strategy_hash.keys.each do |validation_strategy|
              bb_hash[bb].each do |datum|
                if validation_strategy_hash[validation_strategy].nil?
                  bb_error_hash = validation_strategy.call(bb, datum, bb_error_hash, nil, nil)
                else
                  bb_error_hash = validation_strategy.call(bb, datum, bb_error_hash, validation_strategy_hash[validation_strategy][:attribute_names], validation_strategy_hash[validation_strategy][:error_messages])    
                end    
              end
            end
          end  
        end
        # Validation concerning the whole Building Block and all its data 
        validation_whole_data_strategy_hash = bb.validation_whole_data_strategies
        validation_whole_data_strategy_hash.keys.each do |validation_strategy|
          if validation_whole_data_strategy_hash[validation_strategy].nil?
            bb_error_hash = validation_strategy.call(bb, bb_hash[bb], bb_error_hash, nil, nil)
          else
            bb_error_hash = validation_strategy.call(bb, bb_hash[bb], bb_error_hash, validation_whole_data_strategy_hash[validation_strategy][:attribute_names], validation_whole_data_strategy_hash[validation_strategy][:error_messages]) 
          end
#          bb_error_hash = validation_strategy.call(bb, bb_hash[bb], bb_error_hash, validation_whole_data_strategy_hash[validation_strategy], nil) 
        end
      end
    end
    bb_error_hash
  end
  
  
  ##### Methods to make the calling of "additional work strategies" easy ##### 

  
  # This method can be called to do different additional work before saving of 
  # the building_block. It uses the strategies which are asigned to the building
  # block subclass to perform the work needed. The building block is transmitted 
  # and delivered back by each strategy.
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
  # the building_block. It uses the strategies which are asigned to the building
  # block subclass to perform the work needed. The building block is transmitted 
  # and delivered back by each strategy.
  def self.do_additional_work_after_save(re_bb, params)
    additional_work_strategy_hash = re_bb.additional_work_after_save_strategies
    unless additional_work_strategy_hash.empty?
      additional_work_strategy_hash.keys.each do |additional_work_strategy|
        re_bb = additional_work_strategy.call(re_bb, params, additional_work_strategy_hash[additional_work_strategy])    
      end 
    end    
    re_bb
  end
  
  
  ##### Preperation and cleanup methods #####
  

  # This method prevents that a building block is assigned to another
  # artifact_type as it was during its creation. If the building block 
  # has an artifact_type already, this cannot be changed.
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
  
  # If a building block is deleted, it must be deleted from the 
  # user defined "some_attributes_representation" of the artifact 
  # selection building block. Otherwise an exception is thrown and
  # caught so that the "one_line_representation" is rendered instead.
  def delete_occurances_of_bb_from_some_attributes_representation
    bbs_with_some_attribute_representation = ReBuildingBlock.find(:all, :conditions => {:embedding_type => 'attributes'})
    bbs_with_some_attribute_representation.each do |bb|
      attributes_to_show = bb.selected_attributes
      attributes_to_show.delete("re_bb_" + self.id.to_s) unless attributes_to_show.nil?
      bb.selected_attributes = attributes_to_show
      bb.save
    end
  end
  
  
  ##### Helper methods #####
  
  # This method performs an easy string operation to
  # build the data class name from the type of the building block 
  def get_data_class_name
    self.class.to_s.gsub('ReBb', 'ReBbData')
  end
  
  
end
