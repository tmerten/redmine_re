class ReArtifactProperties < ActiveRecord::Base
  unloadable

  # Class attribute to host a hash with all different types of artifacts
  # will be set at Plugin-Start-up. See init.rb of this plugin and module Preparations
  cattr_accessor :artifact_types
  
  # I will place the declaration of the color_to_hex-hash at the bottom of this file as it is rather long
  ARTIFACT_COLOURS = {0 => :DarkViolet, 2 => :BurlyWood, 8 => :Coral, 3 => :Crimson, 4 => :DarkCyan, 5 => :DarkOrange, 6 => :DarkOrchid, 7 => :DarkGoldenRod, 1 => :FireBrick, 9 => :GreenYellow, 10 => :HotPink, 11 => :ForrestGreen, 12 => :DeepSkyBlue, 13 => :DarkSalmon, 14 => :GoldenRod, 15 => :Kahki, 16 => :LightSeaBlue, 17 => :MediumSlateBlue, 18 => :MediumSeaGreen, 19 => :Salmon, 20 => :Teal  }

  RELATION_TYPES = { :parentchild => 1, :dependency => 2, :conflict => 4 }
  RELATION_COLOURS = {0 => :Beige, 1 => :Navy, 2 => :Red, 3 => :Purple, 4 => :Magenta, 5 => :Yellow, 6 => :Green, 7 => :Blue, 8 => :Gold, 9 => :Maroon, 10 => :OrangeRed, 11 => :CadetBlue, 12 => :DarkGreen, 13 => :CornFlowerBlue, 14 => :Pink, 15 => :Indigo, 16 => :Ivory, 17 => :Plum, 18 => :LightSteelBlue, 19 => :Olive, 20 => :MintCream }  

   
  has_many :relationships_as_source,
    :order => "re_artifact_relationships.position",
    :foreign_key => "source_id",
    :class_name => "ReArtifactRelationship",
    :dependent => :destroy

  has_many :relationships_as_sink,
    :order => "re_artifact_relationships.position",
    :foreign_key => "sink_id",
    :class_name => "ReArtifactRelationship",
    :dependent => :destroy
    
  has_many :sinks,    :through => :relationships_as_source, :order => "re_artifact_relationships.position"
  has_many :children, :through => :relationships_as_source, :order => "re_artifact_relationships.position",
    :conditions => [ "re_artifact_relationships.relation_type = ?", Preparation::RELATION_TYPES[:parentchild] ],
    :source => "sink"
  
  has_many :sources, :through => :relationships_as_sink,   :order => "re_artifact_relationships.position"
  has_one :parent, :through => :relationships_as_sink,
    :conditions => [ "re_artifact_relationships.relation_type = ?", Preparation::RELATION_TYPES[:parentchild] ],
    :source => "source"

  belongs_to :artifact, :polymorphic => true #, :dependent => :destroy
  
  # TODO: Implement author and watchable module into the common fields.
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  acts_as_watchable
  

  belongs_to :project
  #belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :project, :created_by, :updated_by, :name
  validates_uniqueness_of :name

  # Should be on, but prevents subtasks from saving for now.
  #validates_numericality_of :priority, :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 50

  # Methods
  attr_accessor :state # Needed to simulate the state for observer
  
  # TODO: Mirsad soll in Englisch schreiben.
  def revert
       #TODO neue version erstellen wenn reverted
       self.state = State::IDLE

       versionNr = self.artifact.version
       version   = self.artifact.versions.find_by_version(versionNr)

       # ReArtifactProperties attribute wiederherstellen
       self.name = version.artifact_name
       self.priority = version.artifact_priority

       self.save
    end

  # Setzt die eigenen zu Versiontabelle hinzugef�gten Spalten
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
     parent.save  # Neue version vom parent(ohne ver�nderung von attributen)

     # gespeicherte Version zwischenspeichern
     savedParentVersion = parent.versions.last

     #--- Version mit zusatzinformation updaten ---
     # Den verursacher(child) zwischenspeichern
     savedParentVersion.versioned_by_artifact_id      = self.id
     savedParentVersion.versioned_by_artifact_version = self.artifact.version

     parent.re_artifact.update_extra_version_columns
     
     savedParentVersion.save
  end
  
  # creates a new relation of type "relation_type" or updates an existing relation
  # from "self" to the re_artifact_properties in "to".
  # (any class that acts_as_re_artifact should also work for "to".)
  #
  # see ReArtifactRelationship::TYPES.keys for valid types
  # the relation will be directed, unless you pass "false" as third argument
  #
  # returns the created relation
  def relate_to(to, relation_type, directed=true)
    raise ArgumentError, "relation_type not valid (see ReArtifactRelationship::TYPES.keys for valid relation_types)" if not Preparation::RELATION_TYPES.has_key?(relation_type)
    
    to = instance_checker to
    
    relation_type_no = Preparation::RELATION_TYPES[relation_type]
    
    # we can not give more than one parent
    if (relation_type == :parentchild) && (! to.parent.nil?) && (to.parent.id != self.id)
        raise ArgumentError, "You are trying to add a second parent to the artifact: #{to}. No ReArtifactRelationship has been created or updated."
    end
    
    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type(self.id, to.id, relation_type_no)
    # new relation    
    if relation.nil?
      self.sinks << to
      relation = self.relationships_as_source.find_by_source_id_and_sink_id self.id, to.id
    else
      if parent.nil?
        ReArtifactRelationships.delete(relation.id)
        return nil
      end
    end
 
    # update properties of new or exising relation
    relation.relation_type = relation_type_no
    relation.directed = directed
    relation.save
    
    relation
  end

  # make parent= work as expected
  # with the exception that we will return the relation not the parent!
  # (create a new parent or replace the current parent)  
  def parent=(parent)
    relation_type_no = Preparation::RELATION_TYPES[:parentchild]
    relation = ReArtifactRelationship.find_by_sink_id_and_relation_type(self.id, relation_type_no)

    if not relation.nil?
      # override existing relation
      if parent.nil?
        ReArtifactRelationship.delete(relation.id)
        return
      end
      parent = instance_checker parent
      relation.source_id = parent.id
      relation.save
    else
      #create new relation
      relation = parent.relate_to self, :parentchild
    end
    
    relation
  end

  # delivers the ID of the re_artifact_properties when the name of the controller and id of sub-artifact is given
    def self.get_properties_id(controllername, subartifact_id)
      @re_artifact_properties = ReArtifactProperties.find_by_artifact_type_and_artifact_id(controllername.camelize, subartifact_id)
      @re_artifact_properties.id
    end

    # set position in scope of parent (source)
  def position=(position)
    raise ArgumentError, "For the current re_artifact_properties object #{self} exist no parent-relation in the database" if not self.parent(true)
    raise ArgumentError, "The current re_artifact_properties object #{self} is not in the database" if not self.id

    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.parent(true).id, #needs true because: http://www.elevatedcode.com/articles/2007/03/16/rails-association-proxies-and-caching/ => "By default, active record only load associations the first time you use them. After that, you can reload them by passing true to the association"
                                                                                       self.id,
                                                                                       Preparation::RELATION_TYPES[:parentchild]
                                                                                     )
    relation.position = position
    relation.save
  end

  #position in scope of parent (source)
  def position()
    raise ArgumentError, "For the current re_artifact_properties object #{self} exist no parent-relation in the database" if not self.parent(true)
    raise ArgumentError, "The current re_artifact_properties object #{self} is not in the database" if not self.id


    relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.parent(true).id,
                                                                                       self.id,
                                                                                       Preparation::RELATION_TYPES[:parentchild]
                                                                                     )
    return relation.position
  end
  
  private
  
  # checks if o is of type re_artifact_properties or acts_as_artifact
  # returns o or o's re_artifact_properties
  def instance_checker(o)
    if not o.instance_of? ReArtifactProperties
      if not o.respond_to? :re_artifact_properties
        raise ArgumentError, "you can relate ReArtifactProperties to other ReArtifactProperties or a class that acts_as_artifact, only."
      end
      o = o.re_artifact_properties
    end
    o    
  end
  
  
  COLOURS_TO_HEX = {:AliceBlue  =>  '#F0F8FF',
                    :AntiqueWhite   =>  '#FAEBD7',
                    :Aqua   =>  '#00FFFF',
                    :Aquamarine   =>  '#7FFFD4',
                    :Azure  =>  '#F0FFFF',
                    :Beige  =>  '#F5F5DC',
                    :Bisque   =>  '#FFE4C4',
                    :Black  =>  '#000000',
                    :BlanchedAlmond   =>  '#FFEBCD',
                    :Blue   =>  '#0000FF',
                    :BlueViolet   =>  '#8A2BE',
                    :Brown  =>  '#A52A2A',
                    :BurlyWood  =>  '#DEB887',
                    :CadetBlue  =>  '#5F9EA0',
                    :Chartreuse   =>  '#7FFF00',
                    :Chocolate  =>  '#D2691E',
                    :Coral  =>  '#FF7F50',
                    :CornflowerBlue   =>  '#6495ED',
                    :Cornsilk   =>  '#FFF8DC',
                    :Crimson  =>  '#DC143C',
                    :Cyan   =>  '#00FFFF',
                    :DarkBlue   =>  '#00008B',
                    :DarkCyan   =>  '#008B8B',
                    :DarkGoldenRod  =>  '#B8860B',
                    :DarkGray   =>  '#A9A9A9',
                    :DarkGrey   =>  '#A9A9A9',
                    :DarkGreen  =>  '#006400',
                    :DarkKhaki  =>  '#BDB76B',
                    :DarkMagenta  =>  '#8B008B',
                    :DarkOliveGreen   =>  '#556B2F',
                    :Darkorange   =>  '#FF8C00',
                    :DarkOrchid   =>  '#9932CC',
                    :DarkRed  =>  '#8B0000',
                    :DarkSalmon   =>  '#E9967A',
                    :DarkSeaGreen   =>  '#8FBC8F',
                    :DarkSlateBlue  =>  '#483D8B',
                    :DarkSlateGray  =>  '#2F4F4F',
                    :DarkSlateGrey  =>  '#2F4F4F',
                    :DarkTurquoise  =>  '#00CED1',
                    :DarkViolet   =>  '#9400D3',
                    :DeepPink   =>  '#FF1493',
                    :DeepSkyBlue  =>  '#00BFFF',
                    :DimGray  =>  '#696969',
                    :DimGrey  =>  '#696969',
                    :DodgerBlue   =>  '#1E90FF',
                    :FireBrick  =>  '#B22222',
                    :FloralWhite  =>  '#FFFAF0',
                    :ForestGreen  =>  '#228B22',
                    :Fuchsia  =>  '#FF00FF',
                    :Gainsboro  =>  '#DCDCDC',
                    :GhostWhite   =>  '#F8F8FF',
                    :Gold   =>  '#FFD700',
                    :GoldenRod  =>  '#DAA520',
                    :Gray   =>  '#808080',
                    :Grey   =>  '#808080',
                    :Green  =>  '#008000',
                    :GreenYellow  =>  '#ADFF2F',
                    :HoneyDew   =>  '#F0FFF0',
                    :HotPink  =>  '#FF69B4',
                    :IndianRed    =>  '#CD5C5C',
                    :Indigo   =>  '#4B0082',
                    :Ivory  =>  '#FFFFF0',
                    :Khaki  =>  '#F0E68C',
                    :Lavender   =>  '#E6E6FA',
                    :LavenderBlush  =>  '#FFF0F5',
                    :LawnGreen  =>  '#7CFC00',
                    :LemonChiffon   =>  '#FFFACD',
                    :LightBlue  =>  '#ADD8E6',
                    :LightCoral   =>  '#F08080',
                    :LightCyan  =>  '#E0FFFF',
                    :LightGoldenRodYellow   =>  '#FAFAD2',
                    :LightGray  =>  '#D3D3D3',
                    :LightGrey  =>  '#D3D3D3',
                    :LightGreen   =>  '#90EE90',
                    :LightPink  =>  '#FFB6C1',
                    :LightSalmon  =>  '#FFA07A',
                    :LightSeaGreen  =>  '#20B2AA',
                    :LightSkyBlue   =>  '#87CEFA',
                    :LightSlateGray   =>  '#778899',
                    :LightSlateGrey   =>  '#778899',
                    :LightSteelBlue   =>  '#B0C4DE',
                    :LightYellow  =>  '#FFFFE0',
                    :Lime   =>  '#00FF00',
                    :LimeGreen  =>  '#32CD32',
                    :Linen  =>  '#FAF0E6',
                    :Magenta  =>  '#FF00FF',
                    :Maroon   =>  '#800000',
                    :MediumAquaMarine   =>  '#66CDAA',
                    :MediumBlue   =>  '#0000CD',
                    :MediumOrchid   =>  '#BA55D3',
                    :MediumPurple   =>  '#9370D8',
                    :MediumSeaGreen   => '#3CB371',
                    :MediumSlateBlue  =>  '#7B68EE',
                    :MediumSpringGreen  =>  '#00FA9A',
                    :MediumTurquoise  =>  '#48D1CC',
                    :MediumVioletRed  =>  '#C71585',
                    :MidnightBlue   =>  '#191970',
                    :MintCream  =>  '#F5FFFA',
                    :MistyRose  =>  '#FFE4E1',
                    :Moccasin   =>  '#FFE4B5',
                    :NavajoWhite  =>  '#FFDEAD',
                    :Navy   =>  '#000080',
                    :OldLace  =>  '#FDF5E6',
                    :Olive  =>  '#808000',
                    :OliveDrab  =>  '#6B8E23',
                    :Orange   =>  '#FFA500',
                    :OrangeRed  =>  '#FF4500',
                    :Orchid   =>  '#DA70D6',
                    :PaleGoldenRod  =>  '#EEE8AA',
                    :PaleGreen  =>  '#98FB98',
                    :PaleTurquoise  =>  '#AFEEEE',
                    :PaleVioletRed  =>  '#D87093',
                    :PapayaWhip   =>  '#FFEFD5',
                    :PeachPuff  =>  '#FFDAB9',
                    :Peru   =>  '#CD853F',
                    :Pink   =>  '#FFC0CB',
                    :Plum   =>  '#DDA0DD',
                    :PowderBlue   =>  '#B0E0E6',
                    :Purple   =>  '#800080',
                    :Red  =>  '#FF0000',
                    :RosyBrown  =>  '#BC8F8F',
                    :RoyalBlue  =>  '#4169E1',
                    :SaddleBrown  =>  '#8B4513',
                    :Salmon   =>  '#FA8072',
                    :SandyBrown   =>  '#F4A460',
                    :SeaGreen   =>  '#2E8B57',
                    :SeaShell   =>  '#FFF5EE',
                    :Sienna   =>  '#A0522D',
                    :Silver   =>  '#C0C0C0',
                    :SkyBlue  =>  '#87CEEB',
                    :SlateBlue  =>  '#6A5ACD',
                    :SlateGray  =>  '#708090',
                    :SlateGrey  =>  '#708090',
                    :Snow   =>  '#FFFAFA',
                    :SpringGreen  =>  '#00FF7F',
                    :SteelBlue  =>  '#4682B4',
                    :Tan  =>  '#D2B48C',
                    :Teal   =>  '#008080',
                    :Thistle  =>  '#D8BFD8',
                    :Tomato   =>  '#FF6347',
                    :Turquoise  =>  '#40E0D0',
                    :Violet   =>  '#EE82EE',
                    :Wheat  =>  '#F5DEB3',
                    :White  =>  '#FFFFFF',
                    :WhiteSmoke   =>  '#F5F5F5',
                    :Yellow   =>  '#FFFF00',
                    :YellowGreen  =>  '#9ACD32'
}
  
end