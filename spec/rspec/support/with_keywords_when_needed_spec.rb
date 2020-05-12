require 'rspec/support/with_keywords_when_needed'

module RSpec::Support
  RSpec.describe "WithKeywordsWhenNeeded" do

    describe ".class_exec" do
      extend RubyFeatures

      let(:klass) do
        Class.new do
          def self.check_argument(argument)
            raise ArgumentError unless argument == 42
          end
        end
      end

      def run(klass, *args, &block)
        WithKeywordsWhenNeeded.class_exec(klass, *args, &block)
      end

      it "will run a block without keyword arguments" do
        run(klass, 42) { |arg| check_argument(arg) }
      end

      it "will run a block with a hash without keyword arguments" do
        run(klass, "value" => 42) { |arg| check_argument(arg["value"]) }
      end

      it "will run a block with optional keyword arguments when none are provided", :if => kw_args_supported? do
        binding.eval(<<-CODE, __FILE__, __LINE__)
        run(klass, 42) { |arg, val: nil| check_argument(arg) }
        CODE
      end

      it "will run a block with optional keyword arguments when they are provided", :if => required_kw_args_supported? do
        binding.eval(<<-CODE, __FILE__, __LINE__)
        run(klass, val: 42) { |val: nil| check_argument(val) }
        CODE
      end

      it "will run a block with required keyword arguments", :if => required_kw_args_supported? do
        binding.eval(<<-CODE, __FILE__, __LINE__)
        run(klass, val: 42) { |val:| check_argument(val) }
        CODE
      end
    end

    describe ".send_to" do
      extend RubyFeatures

      def run(object, *args, &block)
        WithKeywordsWhenNeeded.send_to(object, :run, *args, &block)
      end

      it 'will pass through normal arguments' do
        klass = Class.new { def run(arg); arg; end }
        expect(run(klass.new, 42)).to eq 42
      end

      it 'will pass through a hash when there are no keyword arguments' do
        klass = Class.new { def run(arg); arg; end }
        expect(run(klass.new, "value" => 42)).to eq "value" => 42
      end

      it "will work with optional keyword arguments when none are provided", :if => kw_args_supported? do
        binding.eval(<<-CODE, __FILE__, __LINE__)
        klass = Class.new { def run(arg, val: nil); arg; end }
        expect(run(klass.new, 42)).to eq 42
        CODE
      end

      it "will pass through optional keyword arguments", :if => kw_args_supported? do
        binding.eval(<<-CODE, __FILE__, __LINE__)
        klass = Class.new { def run(val: nil); val; end }
        expect(run(klass.new, val: 42)).to eq 42
        CODE
      end

      it "will pass through required keywork arguments", :if => required_kw_args_supported? do
        binding.eval(<<-CODE, __FILE__, __LINE__)
        klass = Class.new { def run(val:); val; end }
        expect(run(klass.new, val: 42)).to eq 42
        CODE
      end
    end
  end
end
