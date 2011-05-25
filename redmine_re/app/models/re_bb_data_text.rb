class ReBbDataText < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_text
  belongs_to :re_artifact_properties
  
  validates_presence_of :value, :message => "Es muss was eingegeben werden."
  
  def validate()
    bb = ReBuildingBlock.find_by_id(re_bb_text_id)
    valid = true
    unless bb.min_length.nil?
      if value.length < bb.min_length 
        errors.add_to_base(l(:re_bb_too_short, :bb_name => bb.name, :min_length => bb.min_length))       
        valid = false
      end
    end
    unless bb.max_length.nil?
      if value.length > bb.max_length 
        errors.add_to_base(l(:re_bb_too_long, :bb_name => bb.name, :max_length => bb.max_length))
        valid = false
      end
    end
    valid
  end
  
end
