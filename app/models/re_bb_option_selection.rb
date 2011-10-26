class ReBbOptionSelection < ActiveRecord::Base
  unloadable
  
  belongs_to :re_bb_selection
  has_many :re_bb_data_selection
  
end
