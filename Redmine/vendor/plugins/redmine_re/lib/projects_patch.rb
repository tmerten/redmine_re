require_dependency 'project'

module ProjectsPatch
	def self.included(base) # :nodoc:
		base.send(:include, InstanceMethods)
		base.after_save :create_or_update_re_artifact

	#base.class_eval do
	#  alias_method_chain :new, :add_re_project_artifact
	#  alias_method_chain :copy, :add_re_project_artifact
	#end
	end

	module InstanceMethods
		#def new_with_add_re_project_artifact
		#  new_without_add_re_project_artifact
		# 	add_re_artifact_to_project
		#end

		#def copy_with_add_re_project_artifact
		#  copy_without_add_re_project_artifact
		# 	add_re_artifact_to_project
		#end
		
		def create_or_update_re_artifact
			# This method creates or updates the "pseudo" ReArtifact for the project
			# it does this by
			# creating or updating the ReArtifactProperties for this project and setting their type to project
			project_artifact = nil
			#if changed?
				project_artifact = ReArtifactProperties.find_by_artifact_type_and_artifact_id("Project", self.id)
				if project_artifact.nil?
					project_artifact = ReArtifactProperties.new 
					project_artifact.project = self
					project_artifact.created_by = nil # TODO: how to catch a user?
					project_artifact.updated_by = nil # TODO: how to catch a user?
					project_artifact.artifact_type = "Project"
					project_artifact.artifact_id = self.id
					project_artifact.description = self.description
					project_artifact.priority = 50
				end
				project_artifact.name = self.name
				project_artifact.save
			#end
			project_artifact
		end
	end # InstanceMethods

end # Module

Project.send(:include, ProjectsPatch)

