class CreateReAttachments < ActiveRecord::Migration
  def self.up
    create_table :re_attachments do |t|
      t.column :attachment_id, :integer
    end
  end

  def self.down
    drop_table :re_attachments
  end
end
