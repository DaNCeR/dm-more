module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class RequiredFieldValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        value = target.validation_property_value(@field_name)
        property = target.class.properties(target.repository.name)[@field_name]
        return true if present?(value, property.type)

        error_message = @options[:message] || default_error(property.type)
        add_error(target, error_message, @field_name)

        false
      end

      protected

      # Boolean types are considered present if non-nil.
      # Other types are considered present if non-blank.
      def present?(value, property_type)
        boolean_type?(property_type) ? !value.nil? : !value.blank?
      end

      def default_error(property_type)
        actual = boolean_type?(property_type) ? "nil" : "blank"
        "%s must not be #{actual}".t(Extlib::Inflection.humanize(@field_name))
      end

      # Is +type+ a boolean property type?
      #
      # TODO: Consolidate Boolean and TrueClass across DataMapper code
      def boolean_type?(property_type)
        property_type == DM::Boolean || property_type == TrueClass
      end

    end # class RequiredFieldValidator

    module ValidatesPresent

      ##
      # Validates that the specified attribute is present.
      #
      # For most property types "being present" is the same as being "not
      # blank" as determined by the attribute's #blank? method. However, in
      # the case of Boolean, "being present" means not nil; i.e. true or
      # false.
      #
      # @note
      #   dm-core's support lib adds the blank? method to many classes,
      # @see lib/data_mapper/support/blank.rb (dm-core) for more information.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :required_attribute, String
      #     property :another_required, String
      #     property :yet_again, String
      #
      #     validates_present :required_attribute
      #     validates_present :another_required, :yet_again
      #
      #     # a call to valid? will return false unless
      #     # all three attributes are !blank?
      #   end
      def validates_present(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::RequiredFieldValidator)
      end

    end # module ValidatesPresent
  end # module Validate
end # module DataMapper
