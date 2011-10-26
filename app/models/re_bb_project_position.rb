class ReBbProjectPosition < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  belongs_to :re_building_block
  
end
