class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  has_many :re_subtasks, :inverse_of => :re_task, :dependent => :destroy, :order => :position

  accepts_nested_attributes_for :re_subtasks, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['name'].blank? && attributes['solution'].blank? }
end
