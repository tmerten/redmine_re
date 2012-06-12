class ReUseCaseStep < ActiveRecord::Base
  unloadable
  
  belongs_to :re_use_case

  has_many :re_use_case_step_expansion, :dependent => :destroy, :order => :position


  validates_presence_of :re_use_case
  validates_inclusion_of :step_type, :in => 1..2
end
