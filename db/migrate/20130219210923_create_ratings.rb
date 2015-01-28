class CreateRatings < ActiveRecord::Migration
  def up
    create_table :ratings do |t|
      t.string :user_id
      t.string :re_artifact_properties_id
      t.integer :value
    end
  end
  
  def down 
    drop_table(:ratings) if table_exists?
  end
end
