require "issue"


#Mixin for Issue Model
#Connects a Redmine Issue with an RE-Plugin Artifact


module IssuePatch

  def self.include(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
#    base.instance_eval("has_many :realizations")
#    base.instance_eval("has_many: artifacts, :through => :realizations")
    base.class_eval do
      base.has_many :realizations
      base.has_many :re_artifact_properties, :through => :realizations
    end

  end


  module ClassMethods

  end

  module InstanceMethods

  end
end