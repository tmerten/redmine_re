require 'rails_generator/base'
require 'rails_generator/generators/components/controller/controller_generator'

class RedmineReArtifactControllerGenerator < ControllerGenerator
  attr_reader :plugin_path, :plugin_name, :plugin_pretty_name
  
  def initialize(runtime_args, runtime_options = {})
    #runtime_args = runtime_args.dup
    #usage if runtime_args.empty?
    @plugin_name = "redmine_re"
    @plugin_pretty_name = plugin_name.titleize
    @plugin_path = "vendor/plugins/#{plugin_name}"
    super(runtime_args, runtime_options)
  end
  
  def destination_root
    File.join(RAILS_ROOT, plugin_path)
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)
      m.directory File.join('test/functional', class_path)

      # Controller class, functional test, helper class and generic edit view.
      m.template 'controller.rb.erb',
                  File.join('app/controllers',
                            class_path,
                            "#{file_name}_controller.rb") 
                            
      m.template 'functional_test.rb.erb',
                  File.join('test/functional',
                            class_path,
                            "#{file_name}_controller_test.rb")

      m.template 'helper.rb.erb',
                  File.join('app/helpers',
                            class_path,
                            "#{file_name}_helper.rb")
                          
      m.template 'formfields.html.erb',
                  File.join('app/views',
                            class_path,
                            file_name,
                            "_formfields.rhtml")
                            
      m.template 'one_line_view.html.erb',
                  File.join('app/views',
                            class_path,
                            file_name,
                            "_one_line_view.rhtml")
                            

    end
  end
end
