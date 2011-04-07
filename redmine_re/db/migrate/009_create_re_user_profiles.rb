class CreateReUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :re_user_profiles do |t|
    end
  end

  def self.down
    drop_table :re_user_profiles
  end
end
