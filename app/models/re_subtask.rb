class ReSubtask < ActiveRecord::Base
  unloadable

  belongs_to :re_task

  validates_presence_of :re_task
  validates_presence_of :name

  SUBTASK_TYPES = { :Subtask => 0, :Variant => 1, :Problem => 2 }

  acts_as_list
end
