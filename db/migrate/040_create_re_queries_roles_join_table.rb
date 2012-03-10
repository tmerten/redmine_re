class CreateReQueriesRolesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :re_queries_roles, :id => false do |t|
      t.column :query_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :re_queries_roles
  end
end
