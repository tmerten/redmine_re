require_dependency 'project'

module ProjectPatch
  
  def self.included(base)
    base.class_eval do
      #unloadable
      has_many :re_artifact_properties, :dependent => :destroy, :class_name => "ReArtifactProperties"
      has_many :re_settings, :dependent => :destroy
      has_many :re_queries, :dependent => :destroy
    end
  end
  
end

Project.send(:include, ProjectPatch)