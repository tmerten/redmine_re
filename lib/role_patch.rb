require_dependency 'role'

module RolePatch
  def self.included(base)
    base.class_eval do
      unloadable
      has_and_belongs_to_many :re_queries, :join_table => 're_queries_roles', :foreign_key => 'role_id',
                              :association_foreign_key => 'query_id'
    end
  end
end

Role.send(:include, RolePatch)