class ReSubtask < ActiveRecord::Base
  unloadable

  belongs_to :re_task, :inverse_of => :re_subtasks
  validates_presence_of :re_task

  #acts_as_list # do not use. see view/_formfields.rhtml sortable sets each position manually

  SUBTASK_TYPES = { :Subtask => 0, :Variant => 1, :Problem => 2 }

end
