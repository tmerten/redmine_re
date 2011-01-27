class CreateReUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :re_user_profiles do |t|
      t.column :start, :string
      t.column :end, :string
      t.column :frequency, :string
      t.column :difficult, :string
    end
  end

  def self.down
    drop_table :re_user_profiles
  end
end
