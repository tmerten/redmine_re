require_dependency 'user'

module UserPatch

  def self.included(base)
    base.ajaxful_rater
   # base.extend(ClassMethods)
    #base.send(:include, InstanceMethods)

    #typing in class
    #base.class_eval do
    #  unloadable

      #puts base.methods
     # has_many :realizations
     # has_many :re_artifact_properties,  :through => :realizations, :uniq => true

    end

  end
User.send(:include, UserPatch)