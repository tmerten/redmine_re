class Realization < ActiveRecord::Base
  

  belongs_to :issue
  belongs_to :re_artifact_properties

end
