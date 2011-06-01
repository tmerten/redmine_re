class ReArtifactsConfig < ActiveRecord::Base
  unloadable

  after_initialize :init
  
  validates_presence_of :artifact_type
  validates_presence_of :alias_name
  validates_presence_of :color
  validates_presence_of :show_children_in_tree
  validates_presence_of :in_use
  validates_presence_of :printable
  validates_presence_of :overwritable
  validates_presence_of :use_id

  validates_uniqueness_of :alias_name
  
  def init
    self.alias_name ||=  self.artifact_type.sub(/^Re/, '')
    self.color ||= '000000'
    self.icon ||= 'unused'
    self.show_children_in_tree ||= true
    self.in_use ||= true
    self.printable ||= true
    self.overwriteable ||= true
    self.user_id ||= 0
  end

end
