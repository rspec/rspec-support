### 3.0.2 / 2014-06-20
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.1...v3.0.2)

* Revert `BlockSignature` change from 3.0.1 because of a ruby bug that
  caused it to change the block's behavior (https://bugs.ruby-lang.org/issues/9967).
  (Myron Marston, rspec-mocks#721)

### 3.0.1 / 2014-06-19
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0...v3.0.1)

* Fix `BlockSignature` so that it correctly differentiates between
  required and optional block args. (Myron Marston, rspec-mocks#714)

### 3.0.0 / 2014-06-01
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0.rc1...v3.0.0)

### 3.0.0.rc1 / 2014-05-18
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0.beta2...v3.0.0.rc1)

### 3.0.0.beta2 / 2014-02-17
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0.beta1...v3.0.0.beta2)

Bug Fixes:

* Issue message when :replacement is passed to `RSpec.warn_with`. (Jon Rowe)

### 3.0.0.beta1 / 2013-11-07
[Full Changelog](https://github.com/rspec/rspec-support/compare/0dc12d1bdbbacc757a9989f8c09cd08ef3a4837e...v3.0.0.beta1)

Initial release.
