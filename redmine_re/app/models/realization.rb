class Realization < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :re_artifact_property

end
