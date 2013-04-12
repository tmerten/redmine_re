class ReUseCaseStep < ActiveRecord::Base
  unloadable
  
  belongs_to :re_use_case

  has_many :re_use_case_step_expansions, :dependent => :destroy, :order => :position

  accepts_nested_attributes_for :re_use_case_step_expansions, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['description'].blank? && attributes['re_expansion_type'].blank? }

  validates :re_use_case, :presence => true
  validates :step_type, :inclusion => { :in => 1..2}
end
