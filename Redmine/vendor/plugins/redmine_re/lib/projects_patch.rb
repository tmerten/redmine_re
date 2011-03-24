require_dependency 'project'

module ProjectsPatch
	def self.included(base) # :nodoc:
		base.send(:include, InstanceMethods)
		base.after_save :create_or_update_re_artifact
	end

	module InstanceMethods

		def create_or_update_re_artifact
			# This method creates or updates the "pseudo" ReArtifact for the project
			# it does this by
			# creating or updating the ReArtifactProperties for this project and setting their type to "Project"
			project_artifact = nil
      project_artifact = ReArtifactProperties.find_by_artifact_type_and_project_id("Project", self.id)
      if project_artifact.nil?
        project_artifact = ReArtifactProperties.new 
        project_artifact.project = self
        project_artifact.created_by = User.first # is there a better solution?
        project_artifact.updated_by = User.first # actually this is not editable anyway
        project_artifact.artifact_type = "Project"
        project_artifact.artifact_id = self.id
        project_artifact.description = self.description
        project_artifact.priority = 50
      end
      project_artifact.name = self.name
      project_artifact.save
      logger.debug("####### PSEUDO PROJECT ARTIFACT SAVED ######")
			project_artifact
		end

	end # InstanceMethods

end # Module

Project.send(:include, ProjectsPatch)

