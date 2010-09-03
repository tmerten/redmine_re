class AddParentArtifactIdToReArtifact < ActiveRecord::Migration
  def self.up
    change_table :re_artifacts do |t|
      t.integer :parent_artifact_id, :default => nil
    end
    # Todo: Abklaeren, ob man die Constraints braucht. Lassen sich so nicht direkt bei sqlite einfuegen!!!
    # Lassen sich nur dann einfuegen, wenn man die Spalte auch gleich neu erzeugt, dann mit references.
    # siehe hier: http://www.sqlite.org/lang_altertable.html
    #add a foreign key constraint
#    execute <<-SQL
#      ALTER TABLE re_artifacts ADD CONSTRAINT fk_parent_artifact_id FOREIGN KEY (parent_artifact_id) REFERENCES re_artifacts(id)
#    SQL
  end

  def self.down
    # remove foreign key constraint
#    execute <<-SQL
#      ALTER TABLE re_artifacts DROP FOREIGN KEY fk_parent_artifact_id
#    SQL
    remove_column :re_artifacts, :parent_artifact_id
  end

end