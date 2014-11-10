require_dependency 'user'

module UserPatch
  def self.included(base)
    base.class_eval do
      has_many :re_ratings
      has_many :rated_properties, :through => :re_ratings, :source => :re_artifact_properties
    end
  end
end
User.send(:include, UserPatch)