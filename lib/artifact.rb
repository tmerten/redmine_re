module Artifact
  
  def self.included(base)
    base.class_eval do
      has_one :re_artifact_properties, :as => :artifact
    end    
  end

end
