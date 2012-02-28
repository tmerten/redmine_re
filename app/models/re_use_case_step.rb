class ReUseCaseStep < ActiveRecord::Base
  unloadable
  belongs_to :re_use_case

  validates_presence_of :re_use_case
  validates_inclusion_of :step_type, :in => 1..2
end
