class ReUseCaseStepExpansion < ActiveRecord::Base
  unloadable
  belongs_to :re_use_case_step
  
  validates :re_use_case_step, :presence => true
  validates :re_expansion_type, :inclusion => { :in => 1..3 }
end
