class CreateReWorkareas < ActiveRecord::Migration
  def self.up
    create_table :re_workareas do |t|
    end
  end

  def self.down
    drop_table :re_workareas
  end
end
