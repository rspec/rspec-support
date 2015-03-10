require 'rspec/support/object_inspector'
require 'rspec/matchers/fail_matchers'

module RSpec
  module Support
    describe ObjectInspector, ".inspect" do
      context 'with Time objects' do
        let(:time) { Time.utc(1969, 12, 31, 19, 01, 40, 101) }
        let(:formatted_time) { ObjectInspector.inspect(time) }

        it 'produces an extended output' do
          expected_output = "1969-12-31 19:01:40.000101"
          expect(formatted_time).to include(expected_output)
        end
      end

      context 'with DateTime objects' do
        def with_date_loaded
          in_sub_process_if_possible do
            require 'date'
            yield
          end
        end

        let(:date_time) { DateTime.new(2000, 1, 1, 1, 1, Rational(1, 10)) }
        let(:formatted_date_time) { ObjectInspector.inspect(date_time) }

        it 'formats the DateTime using inspect' do
          with_date_loaded do
            expect(formatted_date_time).to eq(date_time.inspect)
          end
        end

        it 'does not require DateTime to be defined since you need to require `date` to make it available' do
          hide_const('DateTime')
          expect(ObjectInspector.inspect('Test String')).to eq('"Test String"')
        end

        context 'when ActiveSupport is loaded' do
          it "uses a custom format to ensure the output is different when DateTimes differ" do
            stub_const("ActiveSupport", Module.new)

            with_date_loaded do
              expected_date_time = 'Sat, 01 Jan 2000 01:01:00.100000000 +0000'
              expect(formatted_date_time).to eq(expected_date_time)
            end
          end
        end
      end

      context 'with BigDecimal objects' do
        let(:float)   { 3.3 }
        let(:decimal) { BigDecimal("3.3") }

        let(:formatted_decimal) { ObjectInspector.inspect(decimal) }

        it 'fails with a conventional representation of the decimal' do
          in_sub_process_if_possible do
            require 'bigdecimal'
            expect(formatted_decimal).to include('3.3 (#<BigDecimal')
          end
        end

        it 'does not require BigDecimal to be defined since you need to require `bigdecimal` to make it available' do
          hide_const('BigDecimal')
          expect(ObjectInspector.inspect('Test String')).to eq('"Test String"')
        end
      end

      context 'with objects that implement description' do
        RSpec::Matchers.define :matcher_with_description do
          match { true }
          description { :description }
        end

        RSpec::Matchers.define :matcher_without_a_description do
          match { true }
          undef description
        end

        it "produces a description when a matcher object has a description" do
          expect(ObjectInspector.inspect(matcher_with_description)).to eq(:description)
        end

        it "does not produce a description unless the object is a matcher" do
          double = double('non-matcher double', :description => true)
          expect(ObjectInspector.inspect(double)).to eq(double.inspect)
        end

        it "produces an inspected object when a matcher is missing a description" do
          expect(ObjectInspector.inspect(matcher_without_a_description)).to eq(
            matcher_without_a_description.inspect)
        end
      end
    end
  end
end
