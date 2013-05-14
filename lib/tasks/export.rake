namespace :export do
  desc "Print artifacts a seeds.rb way." 
  
  #rake export:seeds_format
  task :seeds_format => :environment do
    
    Project.order(:id).all.each do |project|
      puts "Project.create(#{project.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReArtifactProperties.order(:id).all.each do |artifact|
      puts "ReArtifactProperties.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReArtifactRelationship.order(:id).all.each do |relation|
      puts "ReArtifactRelationship.create(#{relation.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end

    ReGoal.order(:id).all.each do |artifact|
      puts "ReGoal.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReProcessword.order(:id).all.each do |artifact|
      puts "ReProcessword.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReRationale.order(:id).all.each do |artifact|
      puts "ReRationale.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReRequirement.order(:id).all.each do |artifact|
      puts "ReRequirement.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReScenario.order(:id).all.each do |artifact|
      puts "ReScenario.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReSection.order(:id).all.each do |artifact|
      puts "ReSection.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReSubtask.order(:id).all.each do |artifact|
      puts "ReSubtask.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReTask.order(:id).all.each do |artifact|
      puts "ReTask.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUseCase.order(:id).all.each do |artifact|
      puts "ReUseCase.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUseCaseStep.order(:id).all.each do |artifact|
      puts "ReUseCaseStep.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUseCaseStepExpansion.order(:id).all.each do |artifact|
      puts "ReUseCaseStepExpansion.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReUserProfile.order(:id).all.each do |artifact|
      puts "ReUserProfile.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReVision.order(:id).all.each do |artifact|
      puts "ReVision.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReAttachment.order(:id).all.each do |artifact|
      puts "ReAttachment.create(#{artifact.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    
    ReSetting.order(:id).all.each do |setting|
      puts "ReSetting.create(#{setting.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end
end