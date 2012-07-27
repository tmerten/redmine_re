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
    base.define_instance_methods
    base.define_delegations_to_artifact_properties
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
      raise NoMethodError, "A #{self} cannot be deleted directly. To delete it use ReArtifactProperties.delete(#{self.to_s.underscore}.artifact_id)"
    end

    def destroy
      raise NoMethodError, "A #{self} cannot be destroyed directly. To destroy it use ReArtifactProperties.destroy(#{self.to_s.underscore}.artifact_id)"
    end

    def define_delegations_to_artifact_properties
      ignored_attributes = ["artifact_type"]

      all_attributes = []
      all_attributes.concat ReArtifactProperties.content_columns.collect{ |c| c.name } # does not return "id"
      all_attributes.concat ReArtifactProperties.reflect_on_all_associations.collect { |a| a.name.to_s }

      attributes_to_delegate = all_attributes - ignored_attributes

      # create delegation methods for attrobutes and associations
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

    def define_instance_methods
      class_eval <<-RUBY
        def artifact_id
          re_artifact_properties.id unless re_artifact_properties.nil?
        end

        def acts_as_artifact_class
          ::#{self.name}
        end

        def delete
          raise NoMethodError,
            "A #{self} cannot be deleted directly. Delete me by using #{self.to_s.underscore}.artifact_properties.delete"
        end

        def destroy
          raise NoMethodError,
            "A #{self} cannot be destroyed directly. Destroy me by using #{self.to_s.underscore}.artifact_properties.delete"
        end
      RUBY
    end
  end

protected

  def re_artifact_properties_must_be_valid
    re_artifact_properties.valid?
  end

end
