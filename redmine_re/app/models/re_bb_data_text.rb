class ReBbDataText < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_text
  belongs_to :re_artifact_properties
  
  def validate_for_specification(bb_error_hash)
    bb = ReBuildingBlock.find_by_id(re_bb_text_id)
    unless bb.min_length.nil?
      if value.length < bb.min_length 
        bb_error_hash[bb.id] = {self.id => []} if bb_error_hash[bb.id].nil?
        bb_error_hash[bb.id][self.id] = [] if bb_error_hash[bb.id][self.id].nil? 
        bb_error_hash[bb.id][self.id] << l(:re_bb_too_short, :bb_name => bb.name, :min_length => bb.min_length)       
      end
    end
    unless bb.max_length.nil?
      if value.length > bb.max_length 
        bb_error_hash[bb.id] = {self.id => []} if bb_error_hash[bb.id].nil?
        bb_error_hash[bb.id][self.id] = [] if bb_error_hash[bb.id][self.id].nil? 
        bb_error_hash[bb.id][self.id] << l(:re_bb_too_long, :bb_name => bb.name, :max_length => bb.max_length)       
      end
    end
    bb_error_hash
  end
  
end
