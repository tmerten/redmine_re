require 'redmine'
module WikiExtensionsWikiMacro

  Redmine::WikiFormatting::Macros.register do

      desc "Generates a link to the artifact with the passed artifact id 
        Example:\n\n<pre>{{a(23)}}</pre>"
      macro :a do |obj, args|
         
         output = ""
         #check if there is only set one argument 
         if args.size != 1
           #there are too many arguments, join them with comma and render macro text
           output =  "{{a(#{args.join(",")})}}"
         else
         
           #check if artifact exists
           artifact = ReArtifactProperties.find_by_id(args)
           if (!artifact.nil?)
             #generate link to artifact#show            
             output << link_to("#{rendered_artifact_type(artifact.artifact_type)} ##{artifact.id}", :controller => 're_artifact_properties', :action => 'show', :project_id => artifact.project_id, :id => artifact.id)
           else
             output = "{{a(#{args})}}"
           end 
         end 
         return output.html_safe         
      
      end
  end
end