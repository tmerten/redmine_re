require_dependency 'project'

module ProjectPatch
  def self.included(base)
    base.class_eval do
      unloadable
      has_many :re_queries, :dependent => :destroy
    end
  end
end

Project.send(:include, ProjectPatch)