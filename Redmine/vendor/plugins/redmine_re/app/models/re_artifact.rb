class ReArtifact < ActiveRecord::Base
  unloadable

  has_many :children,
           :class_name => "ReArtifact",
           :foreign_key => "parent_artifact_id"
  belongs_to :parent, :class_name => 'ReArtifact', :foreign_key => 'parent_artifact_id'

  belongs_to :artifact, :polymorphic => true

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :project, :author, :name
  validates_uniqueness_of :name

  # Methoden
  attr_accessor :isReverting # Als Zustand noetig fuer(observer)

  def revert
       #TODO neue version erstellen wenn reverted
       self.isReverting = false

       versionNr = self.artifact.version
       version   = self.artifact.versions.find_by_version(versionNr)

       # ReArtifact attribute wiederherstellen
       self.name = version.artifact_name
       self.priority = version.artifact_priority

       self.save
    end

  # Setzt die eigenen zu Versiontabelle hinzugefügten Spalten
  def update_extra_version_columns
     versionNr = self.artifact.version
     version   = self.artifact.versions.find_by_version(versionNr)

     version.updated_by        = User.current.id
     version.artifact_name     = self.name
     version.artifact_priority = self.priority

     version.save
  end

  # Versioniert das Elternartifact
  def versioning_parent
     return if self.parent.nil? #Nur wenn ein parent existiert

     parent = self.parent.artifact
     parent.save  # Neue version vom parent(ohne veränderung von attributen)

     # gespeicherte Version zwischenspeichern
     savedParentVersion = parent.versions.last

     #--- Version mit zusatzinformation updaten ---
     # Den verursacher(child) zwischenspeichern
     savedParentVersion.versioned_by_artifact_id      = self.id
     savedParentVersion.versioned_by_artifact_version = self.artifact.version

     parent.re_artifact.update_extra_version_columns
     
     savedParentVersion.save
  end
end