require_dependency 'user'

module UserPatch

  def self.included(base)
    base.ajaxful_rater

    base.class_eval do
      unloadable
      has_many :created_re_queries, :class_name => 'ReQuery', :foreign_key => 'created_by'
      has_many :updated_re_queries, :class_name => 'ReQuery', :foreign_key => 'updated_by'
    end

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