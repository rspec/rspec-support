require 'rspec/support'
require "delegate"

module RSpec
  describe Support do
    describe '.method_handle_for(object, method_name)' do
      untampered_class = Class.new do
        def foo
          :bar
        end
      end

      http_request_class = Struct.new(:method, :uri)

      it 'fetches method definitions for vanilla objects' do
        object = untampered_class.new
        expect(Support.method_handle_for(object, :foo).call).to eq :bar
      end

      it 'fetches method definitions for objects with method redefined' do
        request = http_request_class.new(:get, "http://foo.com/")
        expect(Support.method_handle_for(request, :uri).call).to eq "http://foo.com/"
      end

      context "with a delegator that does not implement a private kernel method" do
        subject {
          Class.new(SimpleDelegator) do
            def foo
              rand(2)
            end
          end
        }

        it "does not issue a warning when stubbing the private kernel method" do
          hash = subject.new({})
          expect(hash).not_to receive(:warn)

          allow(hash).to receive(:rand).and_call_original
          hash.foo
        end

        it "replaces the rand method" do
          hash = subject.new({})
          expect(hash).not_to receive(:warn)

          allow(hash).to receive(:rand).and_return(3)
          expect(hash.foo).to eq(3)
        end

        it "puts the correct rand method back" do
          hash = subject.new({})

          allow(hash).to receive(:rand).and_call_original
          RSpec::Mocks.space.reset_all
          expect(hash.send(:rand)).to be_between(0,1)
        end
      end
      context "with a delegator that does implement a private kernel method" do
        subject {
          Class.new(SimpleDelegator) do
            def rand(n)
              n
            end

            def foo
              rand(2)
            end
          end
        }

        it "does not issue a warning when stubbing the private kernel method" do
          hash = subject.new({})
          expect(hash).not_to receive(:warn)

          allow(hash).to receive(:rand).and_call_original
          hash.foo
        end

        it "gets the correct method with and_call_original" do
          hash = subject.new({})

          allow(hash).to receive(:rand).and_call_original
          expect(hash.foo).to eq(2)
        end

        it "it gets the correct stub implementation" do
          hash = subject.new({})

          allow(hash).to receive(:rand).and_return(3)
          expect(hash.foo).to eq(3)
        end

        it "puts the correct method back" do
          hash = subject.new({})

          allow(hash).to receive(:rand).and_return(3)
          RSpec::Mocks.space.reset_all
          expect(hash.foo).to eq(2)
        end
      end


      context "for a BasicObject subclass", :if => RUBY_VERSION.to_f > 1.8 do
        let(:basic_class) do
          Class.new(BasicObject) do
            def foo
              :bar
            end
          end
        end

        let(:basic_class_with_method_override) do
          Class.new(basic_class) do
            def method
              :method
            end
          end
        end

        let(:basic_class_with_kernel) do
          Class.new(basic_class) do
            include ::Kernel
          end
        end

        let(:basic_class_with_proxying) do
          Class.new(BasicObject) do
            def method_missing(name, *args, &block)
              "foo".__send__(name, *args, &block)
            end
          end
        end

        def self.supports_rebinding_module_methods?
          # RBX doesn't yet support this.
          RUBY_VERSION.to_i >= 2 && RUBY_ENGINE != 'rbx'
        end

        it 'still works', :if => supports_rebinding_module_methods? do
          object = basic_class.new
          expect(Support.method_handle_for(object, :foo).call).to eq :bar
        end

        it 'works when `method` has been overriden', :if => supports_rebinding_module_methods? do
          object = basic_class_with_method_override.new
          expect(Support.method_handle_for(object, :foo).call).to eq :bar
        end

        it 'allows `method` to be proxied', :unless => supports_rebinding_module_methods? do
          object = basic_class_with_proxying.new
          expect(Support.method_handle_for(object, :reverse).call).to eq "oof"
        end

        it 'still works when Kernel has been mixed in' do
          object = basic_class_with_kernel.new
          expect(Support.method_handle_for(object, :foo).call).to eq :bar
        end
      end
    end
  end
end
