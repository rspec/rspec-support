# encoding: utf-8
require 'spec_helper'
require 'ostruct'
require 'timeout'
require 'rspec/support/spec/string_matcher'

module RSpec
  module Support
    describe Differ do
      describe '#diff' do
        let(:differ) { RSpec::Support::Differ.new }

        it "outputs unified diff of two strings" do
          expected = "foo\nzap\nbar\nthis\nis\nsoo\nvery\nvery\nequal\ninsert\na\nanother\nline\n"
          actual   = "foo\nbar\nzap\nthis\nis\nsoo\nvery\nvery\nequal\ninsert\na\nline\n"

          expected_diff = <<-'EOD'


@@ -1,6 +1,6 @@
 foo
-zap
 bar
+zap
 this
 is
 soo
@@ -9,6 +9,5 @@
 equal
 insert
 a
-another
 line
EOD

          diff = differ.diff(actual, expected)
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "outputs unified diff of two strings when used multiple times" do
          expected = "foo\nzap\nbar\nthis\nis\nsoo\nvery\nvery\nequal\ninsert\na\nanother\nline\n"
          actual   = "foo\nbar\nzap\nthis\nis\nsoo\nvery\nvery\nequal\ninsert\na\nline\n"

          expected_diff = dedent(<<-'EOS')
            |
            |
            |@@ -1,6 +1,6 @@
            | foo
            |-zap
            | bar
            |+zap
            | this
            | is
            | soo
            |@@ -9,6 +9,5 @@
            | equal
            | insert
            | a
            |-another
            | line
            |
          EOS

          diff = differ.diff(actual, expected)
          expect(diff).to be_diffed_as(expected_diff)
        end

        it 'does not mutate any instance variables when diffing, so we can reason about it being reused' do
          expected = "foo\nzap\nbar\nthis\nis\nsoo\nvery\nvery\nequal\ninsert\na\nanother\nline\n"
          actual   = "foo\nbar\nzap\nthis\nis\nsoo\nvery\nvery\nequal\ninsert\na\nline\n"

          expect { differ.diff(actual, expected) }.not_to change { differ_ivars }
        end

        def differ_ivars
          Hash[ differ.instance_variables.map do |ivar|
            [ivar, differ.instance_variable_get(ivar)]
          end ]
        end

        if String.method_defined?(:encoding)

          it "returns an empty string if strings are not multiline" do
            expected = "Tu avec carte {count} item has".encode('UTF-16LE')
            actual   = "Tu avec carté {count} itém has".encode('UTF-16LE')


            diff = differ.diff(actual, expected)
            expect(diff).to be_empty
          end

          it 'copes with encoded strings' do
            expected = "Tu avec carte {count} item has\n".encode('UTF-16LE')
            actual   = "Tu avec carté {count} itém has\n".encode('UTF-16LE')
            expected_diff = <<-EOD.encode('UTF-16LE')

@@ -1,2 +1,2 @@
-Tu avec carte {count} item has
+Tu avec carté {count} itém has
EOD

            diff = differ.diff(actual, expected)
            expect(diff).to be_diffed_as(expected_diff)
          end

          it 'handles differently encoded strings that are compatible' do
            expected = "abc\n".encode('us-ascii')
            actual   = "강인철\n".encode('UTF-8')
            expected_diff = "\n@@ -1,2 +1,2 @@\n-abc\n+강인철\n"
            diff = differ.diff(actual, expected)
            expect(diff).to be_diffed_as(expected_diff)
          end

          it 'uses the default external encoding when the two strings have incompatible encodings', :failing_on_appveyor do
            expected = "Tu avec carte {count} item has\n"
            actual   = "Tu avec carté {count} itém has\n".encode('UTF-16LE')
            expected_diff = "\n@@ -1,2 +1,2 @@\n-Tu avec carte {count} item has\n+Tu avec carté {count} itém has\n"

            diff = differ.diff(actual, expected)
            expect(diff).to be_diffed_as(expected_diff)
            expect(diff.encoding).to eq(Encoding.default_external)
          end

          it 'handles any encoding error that occurs with a helpful error message' do
            expect(RSpec::Support::HunkGenerator).to receive(:new).
              and_raise(Encoding::CompatibilityError)
            expected = "Tu avec carte {count} item has\n".encode('us-ascii')
            actual   = "Tu avec carté {count} itém has\n"
            diff = differ.diff(actual, expected)
            expect(diff).to match(/Could not produce a diff/)
            expect(diff).to match(/actual string \(UTF-8\)/)
            expect(diff).to match(/expected string \(US-ASCII\)/)
          end
        end

        it "outputs unified diff message of two objects" do
          animal_class = Class.new do
            def initialize(name, species)
              @name, @species = name, species
            end

            def inspect
              <<-EOA
<Animal
  name=#{@name},
  species=#{@species}
>
              EOA
            end
          end

          expected = animal_class.new "bob", "giraffe"
          actual   = animal_class.new "bob", "tortoise"

          expected_diff = <<'EOD'

@@ -1,5 +1,5 @@
 <Animal
   name=bob,
-  species=tortoise
+  species=giraffe
 >
EOD

          diff = differ.diff(expected,actual)
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "outputs unified diff message of two arrays" do
          expected = [ :foo, 'bar', :baz, 'quux', :metasyntactic, 'variable', :delta, 'charlie', :width, 'quite wide' ]
          actual   = [ :foo, 'bar', :baz, 'quux', :metasyntactic, 'variable', :delta, 'tango'  , :width, 'very wide'  ]

          expected_diff = <<'EOD'


@@ -5,7 +5,7 @@
  :metasyntactic,
  "variable",
  :delta,
- "tango",
+ "charlie",
  :width,
- "very wide"]
+ "quite wide"]
EOD

          diff = differ.diff(expected,actual)
          expect(diff).to be_diffed_as(expected_diff)
        end

        it 'outputs a unified diff message for an array which flatten recurses' do
          klass = Class.new do
            def to_ary; [self]; end
            def inspect; "<BrokenObject>"; end
          end
          obj = klass.new

          diff = ''
          Timeout::timeout(1) do
            diff = differ.diff [obj], []
          end

          expected_diff = <<-EOD

@@ -1,2 +1,2 @@
-[]
+[<BrokenObject>]
EOD
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "outputs unified diff message of two hashes" do
          expected = { :foo => 'bar', :baz => 'quux', :metasyntactic => 'variable', :delta => 'charlie', :width =>'quite wide' }
          actual   = { :foo => 'bar', :metasyntactic => 'variable', :delta => 'charlotte', :width =>'quite wide' }

          expected_diff = <<'EOD'

@@ -1,4 +1,5 @@
-:delta => "charlotte",
+:baz => "quux",
+:delta => "charlie",
 :foo => "bar",
 :metasyntactic => "variable",
 :width => "quite wide",
EOD

          diff = differ.diff(expected,actual)
          expect(diff).to be_diffed_as(expected_diff)
        end

        it 'outputs unified diff message of two hashes with differing encoding', :failing_on_appveyor do
          expected_diff = %Q{
@@ -1,2 +1,2 @@
-"a" => "a",
#{ (RUBY_VERSION.to_f > 1.8) ?  %Q{+"ö" => "ö"} : '+"\303\266" => "\303\266"' },
}

          diff = differ.diff({'ö' => 'ö'}, {'a' => 'a'})
          expect(diff).to be_diffed_as(expected_diff)
        end

        it 'outputs unified diff message of two hashes with encoding different to key encoding', :failing_on_appveyor do
          expected_diff = %Q{
@@ -1,2 +1,2 @@
-:a => "a",
#{ (RUBY_VERSION.to_f > 1.8) ?  %Q{+\"한글\" => \"한글2\"} : '+"\355\225\234\352\270\200" => "\355\225\234\352\270\2002"' },
}

          diff = differ.diff({ "한글" => "한글2"}, { :a => "a"})
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "outputs unified diff message of two hashes with object keys" do
          expected_diff = %Q{
@@ -1,2 +1,2 @@
-["a", "c"] => "b",
+["d", "c"] => "b",
}

          diff = differ.diff({ ['d','c'] => 'b'}, { ['a','c'] => 'b' })
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "outputs unified diff of multi line strings" do
          expected = "this is:\n  one string"
          actual   = "this is:\n  another string"

          expected_diff = <<'EOD'

@@ -1,3 +1,3 @@
 this is:
-  another string
+  one string
EOD

          diff = differ.diff(expected,actual)
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "splits items with newlines" do
          expected_diff = <<'EOD'

@@ -1,3 +1 @@
-a\nb
-c\nd
EOD

          diff = differ.diff [], ["a\nb", "c\nd"]
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "shows inner arrays on a single line" do
          expected_diff = <<'EOD'

@@ -1,3 +1 @@
-a\nb
-["c\nd"]
EOD

          diff = differ.diff [], ["a\nb", ["c\nd"]]
          expect(diff).to be_diffed_as(expected_diff)
        end

        it "returns an empty string if no expected or actual" do
          diff = differ.diff nil, nil

          expect(diff).to be_empty
        end

        it "returns an empty string if expected is Numeric" do
          diff = differ.diff 1, "2"

          expect(diff).to be_empty
        end

        it "returns an empty string if actual is Numeric" do
          diff = differ.diff "1", 2

          expect(diff).to be_empty
        end

        it "returns an empty string if expected or actual are procs" do
          diff = differ.diff lambda {}, lambda {}

          expect(diff).to be_empty
        end

        it "returns a String if no diff is returned" do
          diff = differ.diff 1, 2
          expect(diff).to be_a(String)
        end

        it "returns a String if a diff is performed" do
          diff = differ.diff "a\n", "b\n"
          expect(diff).to be_a(String)
        end

        context "with :object_preparer option set" do
          let(:differ) do
            RSpec::Support::Differ.new(:object_preparer => lambda { |s| s.to_s.reverse })
          end

          it "uses the output of object_preparer for diffing" do
            expected = :foo
            actual = :poo

            expected_diff = dedent(<<-EOS)
              |
              |@@ -1,2 +1,2 @@
              |-"oop"
              |+"oof"
              |
            EOS

            diff = differ.diff(expected, actual)
            expect(diff).to be_diffed_as(expected_diff)
          end
        end

        context "with :color option set" do
          let(:differ) { RSpec::Support::Differ.new(:color => true) }

          it "outputs colored diffs" do
            expected = "foo bar baz\n"
            actual = "foo bang baz\n"
            expected_diff = "\e[0m\n\e[0m\e[34m@@ -1,2 +1,2 @@\n\e[0m\e[31m-foo bang baz\n\e[0m\e[32m+foo bar baz\n\e[0m"

            diff = differ.diff(expected,actual)
            expect(diff).to be_diffed_as(expected_diff)
          end
        end
      end
    end
  end
end
