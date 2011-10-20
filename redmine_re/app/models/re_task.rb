class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  has_many :re_subtasks, :dependent => :destroy, :order => :position
  accepts_nested_attributes_for :re_subtasks, :allow_destroy => true
end
