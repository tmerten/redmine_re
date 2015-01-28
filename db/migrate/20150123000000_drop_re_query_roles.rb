class DropReQueryRoles < ActiveRecord::Migration
  def self.up
    drop_table :re_queries_roles
    change_column :re_queries, :source, :text
    change_column :re_queries, :sink, :text
    change_column :re_queries, :issue, :text
    change_column :re_queries, :order, :text
  end

  def self.down
    create_table :re_queries_roles, :id => false do |t|
      t.column :query_id, :integer
      t.column :role_id, :integer
    end
  end
end