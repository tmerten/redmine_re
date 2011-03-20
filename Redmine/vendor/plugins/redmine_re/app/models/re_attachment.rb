class ReAttachment < ActiveRecord::Base
  unloadable
  
  acts_as_re_artifact

  belongs_to :attachment
end
