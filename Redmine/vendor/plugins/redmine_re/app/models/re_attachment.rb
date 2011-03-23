class ReAttachment < ActiveRecord::Base
  unloadable
  
  acts_as_re_artifact
  acts_as_attachable :after_remove => :attachment_removed

  belongs_to :attachment
end
