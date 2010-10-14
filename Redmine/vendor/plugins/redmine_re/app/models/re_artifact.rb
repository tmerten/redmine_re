class ReArtifact < ActiveRecord::Base
  unloadable

  has_many :children,
           :class_name => "ReArtifact",
           :foreign_key => "parent_artifact_id",
           :dependent => :nullify
  
  belongs_to :parent, :class_name => 'ReArtifact', :foreign_key => 'parent_artifact_id'

  belongs_to :artifact, :polymorphic => true

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :project, :author, :name
  validates_uniqueness_of :name

  # Methoden
  attr_accessor :state # Als Zustand noetig fuer(observer)
 

  def revert
       #TODO neue version erstellen wenn reverted
       self.state = State::IDLE

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

     version.updated_by         = User.current.id
     version.artifact_name      = self.name
     version.artifact_priority  = self.priority
     version.parent_artifact_id = self.parent_artifact_id

     version.save
  end

#  def create_new_version
#     versionNr = self.artifact.version
#     version   = self.artifact.versions.find_by_version(versionNr)
#     Rails.logger.debug("####### create new version#########1 version" + version.inspect )
#     new_version = version.clone
#     Rails.logger.debug("####### create new version#########2 version/ new version" + version.inspect + "\n" + new_version.inspect)
#
#     new_version.version = new_version.version.to_i + 1
#     #new_version.id += 1
#     Rails.logger.debug("####### create new version######### version/ new version" + version.inspect + "\n" + new_version.inspect + "\n artifact vers" + self.artifact.version.to_s)
#
#
#     self.artifact.without_revision do
#        self.artifact.version  = new_version.version
#        self.artifact.save
#     end
#     Rails.logger.debug("####### create new version######### artifact" + self.artifact.inspect)
#
#     new_version.save
#  end

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