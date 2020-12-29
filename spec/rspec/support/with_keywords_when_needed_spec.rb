require 'rspec/support/with_keywords_when_needed'

module RSpec::Support
  RSpec.describe "WithKeywordsWhenNeeded" do
    describe ".class_exec" do
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

      it "will run a block with optional keyword arguments when none are provided" do
        run(klass, 42) { |arg, val: nil| check_argument(arg) }
      end

      it "will run a block with optional keyword arguments when they are provided" do
        run(klass, val: 42) { |val: nil| check_argument(val) }
      end

      it "will run a block with required keyword arguments" do
        run(klass, val: 42) { |val:| check_argument(val) }
      end
    end

    describe ".call" do
      let(:klass) do
        Class.new do
          class << self
            def meth1(argument)
              raise ArgumentError unless argument == 42
            end

            def meth2(hash)
              raise ArgumentError unless hash["value"] == 42
            end

            def meth3(argument, val: nil)
              raise ArgumentError unless argument == 42
            end

            def meth4(val: nil)
              raise ArgumentError unless val == 42
            end

            def meth5(val:)
              raise ArgumentError unless val == 42
            end
          end
        end
      end

      def run(klass, *args, &block)
        method = klass.method(:check_argument)
        WithKeywordsWhenNeeded.call(method, *args, &block)
      end

      it "will run a method without keyword arguments" do
        WithKeywordsWhenNeeded.call(klass.method(:meth1), 42)
      end

      it "will run a method with a hash without keyword arguments" do
        WithKeywordsWhenNeeded.call(klass.method(:meth2), "value" => 42)
      end

      it "will run a method with optional keyword arguments when none are provided" do
        WithKeywordsWhenNeeded.call(klass.method(:meth3), 42)
      end

      it "will run a method with optional keyword arguments when they are provided" do
        WithKeywordsWhenNeeded.call(klass.method(:meth4), val: 42)
      end

      it "will run a method with required keyword arguments" do
        WithKeywordsWhenNeeded.call(klass.method(:meth5), val: 42)
      end
    end
  end
end
