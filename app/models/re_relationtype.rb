class ReRelationtype < ActiveRecord::Base
  unloadable
  
  #validates :id, :presence => true, :numericality => true
  #validates :project_id, :presence => true, :numericality => true
  #validates :relation_type, :presence => true
  #validates :alias_name, :presence => true
  #validates :color, :format => { :with => /^#\d{6}$/}
  #validates :is_system_relation, :inclusion => { :in => [true, false] }
  #validates :is_directed, :inclusion => { :in => [true, false] }
  #validates :in_use, :inclusion => { :in => [true, false] }
  
  def self.relation_types (project_id, is_system_relation=nil, is_used_relation=nil)
    relation_types = []
    tmp = nil
    if is_system_relation == nil
      if is_used_relation == nil
         tmp = ReRelationtype.find_all_by_project_id(project_id)
      else
        tmp = ReRelationtype.find_all_by_project_id_and_in_use(project_id, is_used_relation)
      end  
    else
      if is_used_relation == nil
        tmp = ReRelationtype.find_all_by_project_id_and_is_system_relation(project_id, is_system_relation)
      else 
        tmp = ReRelationtype.find_all_by_project_id_and_is_system_relation_and_in_use(project_id, is_system_relation, is_used_relation)
      end
    end
    tmp.each do |relationtype|
        relation_types << relationtype.relation_type
    end
    relation_types
  end
  
    
  def self.in_use (relation_type, project_id)

    ret = false
    tmp = ReRelationtype.find_by_project_id_and_relation_type_and_in_use(project_id, relation_type, 1)
    unless tmp.blank?
      ret = true
    end
    ret
  end
    
  def self.get_alias_name (relation_type, project_id)

    ret = ""
    tmp = ReRelationtype.find_by_project_id_and_relation_type(project_id, relation_type)

    unless tmp.blank?
      ret = tmp.alias_name
    end
    ret
  end

end