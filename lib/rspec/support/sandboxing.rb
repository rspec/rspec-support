module RSpec
  module Support
    module Sandboxing
      def self.sandboxed(&block)
        orig_load_path = $LOAD_PATH.dup
        orig_config = RSpec.configuration
        orig_world  = RSpec.world
        orig_example = RSpec.current_example

        new_config = generate_config
        new_world  = RSpec::Core::World.new(new_config)

        RSpec.configuration = new_config
        RSpec.world = new_world
        temporary_scope_mock(block)
      ensure
        RSpec.configuration = orig_config
        RSpec.world = orig_world
        RSpec.current_example = orig_example
        $LOAD_PATH.replace(orig_load_path)
      end

    private

      def self.generate_config
        new_config = RSpec::Core::Configuration.new
        new_config.expose_dsl_globally = false
        new_config.expecting_with_rspec = true
        new_config
      end

      def self.temporary_scope_mock(block)
        object = Object.new
        object.extend(RSpec::Core::SharedExampleGroup)
        RSpec::Mocks.with_temporary_scope do
          object.instance_exec(&block)
        end
      end
    end
  end
end
