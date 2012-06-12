class ReUseCaseStepExpansion < ActiveRecord::Base
  unloadable
  belongs_to :re_use_case_step

  validates_presence_of :re_use_case_step
  validates_inclusion_of :re_expansion_type, :in => 1..3
end
