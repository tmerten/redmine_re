class ReBbDataSelection < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_selection
  belongs_to :re_artifact_properties
  belongs_to :re_bb_option_selection
  
  # This method seems to be not called from anywhere. Please check this!
  def validate_for_specification(bb_error_hash)
    bb_error_hash
  end
   
end
