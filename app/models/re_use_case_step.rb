class ReUseCaseStep < ActiveRecord::Base
  unloadable
  
  belongs_to :re_use_case

  has_many :re_use_case_step_expansions, :dependent => :destroy, :order => :position

  accepts_nested_attributes_for :re_use_case_step_expansions, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['description'].blank? && attributes['re_expansion_type'].blank? }

  validates_presence_of :re_use_case
  validates_inclusion_of :step_type, :in => 1..2
end
