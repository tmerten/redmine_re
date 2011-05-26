class CreateReArtifactsConfigs < ActiveRecord::Migration
  def self.up
    create_table :re_artifacts_configs do |t|
      t.column :artifact_type, :string
      t.column :alias_name, :string
      t.column :color, :string
      t.column :icon, :string
      t.column :show_children_in_tree, :bool
      t.column :allowed_children, :text
      t.column :hide_fields, :text
      t.column :in_use, :bool
      t.column :printable, :bool
      t.column :position, :integer
      t.column :overwriteable, :bool
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :re_artifacts_configs
  end
end
