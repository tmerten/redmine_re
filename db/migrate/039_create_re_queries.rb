class CreateReQueries < ActiveRecord::Migration
  def self.up
    create_table :re_queries do |t|
      t.column :project_id, :integer

      t.column :name, :string
      t.column :description, :text
      t.column :visibility, :string
      t.column :editable, :boolean

      t.column :source, :string
      t.column :sink, :string
      t.column :issue, :string
      t.column :order, :string

      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :re_queries
  end
end
