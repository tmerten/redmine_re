class ReUseCase < ActiveRecord::Base
  unloadable
  
  acts_as_re_artifact

  has_many :re_use_case_steps, :inverse_of => :re_use_case, :dependent => :destroy, :order => :position
  #has_many :re_use_case_step_expansions, :through => :re_use_case_step

  accepts_nested_attributes_for :re_use_case_steps, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['description'].blank? && attributes['step_type'].blank? }

end
