module Artifact
  def self.included(base)
    base.has_one :re_artifact_properties, :as => :artifact, :autosave => true, :dependent => :destroy
    base.validates_presence_of :re_artifact_properties
    base.validate :re_artifact_properties_must_be_valid
    base.alias_method_chain :re_artifact_properties, :autobuild
    base.extend ClassMethods
    base.define_re_artifact_properties_accessors
  end

  def re_artifact_properties_with_autobuild
    re_artifact_properties_without_autobuild || build_re_artifact_properties
  end
  
  def method_missing(meth, *args, &blk)
    re_artifact_properties.send(meth, *args, &blk)
  rescue NoMethodError
    super
  end

  module ClassMethods
    def define_re_artifact_properties_accessors
      all_attributes = ReArtifactProperties.content_columns.map(&:name)
      ignored_attributes = ["created_at", "updated_at", "sellable_type"]
      attributes_to_delegate = all_attributes - ignored_attributes
      
      class_eval <<-RUBY
        def artifact_id
          re_artifact_properties.id unless re_artifact_properties.nil?
        end

        def acts_as_artifact_class
          ::#{self.name}
        end
      RUBY

      attributes_to_delegate.each do |attrib|
        class_eval <<-RUBY
          def #{attrib}
            re_artifact_properties.#{attrib}
          end

          def #{attrib}=(value)
            self.re_artifact_properties.#{attrib} = value
          end

          def #{attrib}?
            self.re_artifact_properties.#{attrib}?
          end
        RUBY
      end
    end
  end

protected

  def re_artifact_properties_must_be_valid
    re_artifact_properties.valid?
  end
  
end
