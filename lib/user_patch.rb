require_dependency 'user'

module UserPatch
  def self.included(base)
    base.class_eval do
      has_many :ratings
      has_many :rated_properties, :through => :ratings, :source => :re_artifact_properties
      #has_many :created_re_queries, :class_name => 'ReQuery', :foreign_key => 'created_by'
      #has_many :updated_re_queries, :class_name => 'ReQuery', :foreign_key => 'updated_by'
    end
  end
end
User.send(:include, UserPatch)