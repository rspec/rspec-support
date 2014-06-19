require 'rspec/support'

module RSpec
  describe Support do
    extend Support::RubyFeatures

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

    describe ".proc_to_lambda" do
      context "on an interpreter that provides Proc#lambda?", :if => Proc.method_defined?(:lambda?) do
        it "converts a proc to a lambda" do
          p = Proc.new { 47 }
          expect(p).not_to be_lambda
          l = Support.proc_to_lambda(p)
          expect(l).to be_lambda
          expect(l.call).to eq(47)
        end

        it 'returns a lambda unchanged' do
          l = lambda { }
          expect(Support.proc_to_lambda(l)).to be(l)
        end
      end

      context "on an interpreter that does not provide Proc#lambda?", :unless => Proc.method_defined?(:lambda?) do
        it 'converts a proc to a lambda' do
          p = Proc.new { return 47 }
          l = Support.proc_to_lambda(p)
          expect(l.call).to eq(47)
        end
      end
    end
  end
end
