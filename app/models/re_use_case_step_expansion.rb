class ReUseCaseStepExpansion < ActiveRecord::Base
  unloadable
  belongs_to :re_use_case_step
  
  validates :re_use_case_step, :presence => true
  validates :re_expansion_type, :inclusion => { :in => 1..3 }
  
  def expansion_type_translation_key
    translation_keys = { 1 => :re_exception_expansion, 2 => :re_data_expansion, 3 => :re_other_expansion }
    translation_keys[re_expansion_type]
  end
end
