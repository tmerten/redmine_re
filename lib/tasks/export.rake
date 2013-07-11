namespace :export do
  desc "Print artifacts a seeds.rb way." 
  
  #rake export:seeds_format
  task :seeds_format => :environment do
    
    Project.order(:id).all.each do |project|
      puts "Project.create(#{project.serializable_hash.delete_if {|key, value| ['lft','rgt','status','created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    #Setting.order(:id).all.each do |setting|
    #  puts "Setting.create(#{setting.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    #end
    
    #Role.order(:id).all.each do |role|
    #  puts "r=Role.create(#{role.serializable_hash.delete_if {|key, value| ['builtin','created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    #  if role.name=="Non member"
    #    puts "r.buildin=1"
    #    puts "r.save"
    #  elsif role.name=="Anonymous"
    #    puts "r.buildin=2"
    #    puts "r.save"
    #  end
    #end

    EnabledModule.order(:id).all.each do |em|
      puts "EnabledModule.create(#{em.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReArtifactProperties.order(:id).all.each do |artifact|
      parentrelation = ReArtifactRelationship.find_by_sink_id(artifact.id)
      unless parentrelation.nil?
        parentartifact = ReArtifactProperties.find(parentrelation.source_id)
        puts "ReArtifactProperties.create(#{artifact.serializable_hash.delete_if {|key, value| ['rating_average','created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')},"
        puts "\"parent\" => ReArtifactProperties.find(#{parentrelation.source_id}),"
        puts "\"parent_relation\" => ReArtifactRelationship.find_by_sink_id(#{artifact.id}))"
      else
        puts "ReArtifactProperties.create(#{artifact.serializable_hash.delete_if {|key, value| ['rating_average','created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
      end
    end

    ReGoal.order(:id).all.each do |artifact|
      puts "ReGoal.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReProcessword.order(:id).all.each do |artifact|
      puts "ReProcessword.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReRationale.order(:id).all.each do |artifact|
      puts "ReRationale.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReRequirement.order(:id).all.each do |artifact|
      puts "ReRequirement.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReScenario.order(:id).all.each do |artifact|
      puts "ReScenario.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReSection.order(:id).all.each do |artifact|
      puts "ReSection.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReSubtask.order(:id).all.each do |artifact|
      puts "ReSubtask.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReTask.order(:id).all.each do |artifact|
      puts "ReTask.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUseCase.order(:id).all.each do |artifact|
      puts "ReUseCase.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUseCaseStep.order(:id).all.each do |artifact|
      puts "ReUseCaseStep.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUseCaseStepExpansion.order(:id).all.each do |artifact|
      puts "ReUseCaseStepExpansion.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUserProfile.order(:id).all.each do |artifact|
      puts "ReUserProfile.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReVision.order(:id).all.each do |artifact|
      puts "ReVision.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReAttachment.order(:id).all.each do |artifact|
      puts "ReAttachment.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReSetting.order(:id).all.each do |setting|
      n   = "#{setting.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s}"
      puts "ReSetting.create(#{setting.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s[1, n.length-2]})"
    end
    
    ReArtifactRelationship.order(:id).all.each do |relation|
      puts "ReArtifactRelationship.create(#{relation.serializable_hash.delete_if {|key, value| ['created_on','updated_on','created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
  end
end