module Artifact
  def self.included(base)
    base.has_one :re_artifact_properties, :as => :artifact, :autosave => true
    # dependent => destroy does not work here and will cause a recursive call
    # to the artifact_properties and back...

    base.validates_presence_of :re_artifact_properties
    base.validate :re_artifact_properties_must_be_valid

    base.alias_method_chain :re_artifact_properties, :build
    base.alias_attribute :artifact_properties, :re_artifact_properties

    base.extend ClassMethods
    base.define_re_artifact_properties_accessors
  end

  def re_artifact_properties_with_build
    re_artifact_properties_without_build || build_re_artifact_properties
  end

  def method_missing(meth, *args, &blk)
    re_artifact_properties.send(meth, *args, &blk)
  rescue NoMethodError
    super
  end

  module ClassMethods

    def delete
      raise NoMethodError, "You cannot delete this object, delete the according re_artifact_properties instead"
    end

    def destroy
      raise NoMethodError, "You cannot destroy this object, destroy the according re_artifact_properties instead"
    end

    def define_re_artifact_properties_accessors
      all_attributes = ReArtifactProperties.content_columns.map(&:name)
      ignored_attributes = ["artifact_type"]
      attributes_to_delegate = all_attributes - ignored_attributes

      class_eval <<-RUBY
        def artifact_id
          re_artifact_properties.id unless re_artifact_properties.nil?
        end

        def acts_as_artifact_class
          ::#{self.name}
        end

        def delete
          raise NoMethodError, "You cannot delete an object of this type, delete the according re_artifact_properties instead"
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
