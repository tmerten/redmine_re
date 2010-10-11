class ReGoal < ActiveRecord::Base
  unloadable

  has_one :re_artifact, :as => :artifact, :dependent => :destroy
  accepts_nested_attributes_for :re_artifact, :allow_destroy => true
  
end