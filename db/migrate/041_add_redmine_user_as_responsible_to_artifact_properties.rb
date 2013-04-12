class AddRedmineUserAsResponsibleToArtifactProperties < ActiveRecord::Migration
  def self.up
    add_column :re_artifact_properties, "responsible_id", :integer
    
    ReArtifactProperties.all.each do |artifact|
      
      unless artifact.responsibles.blank?
      
        old_user_name = artifact.responsibles.split(" ");
        
        if old_user_name.length == 2
          
          redmine_user = User.find_by_firstname_and_lastname(old_user_name[0], old_user_name[1])
          
          artifact.responsible_id = redmine_user.id
          artifact.save
    
        end #if             
      end #unless     
    end #each
    
    remove_column :re_artifact_properties, :responsibles

  end #up

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

