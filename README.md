# RSpec::Support

`RSpec::Support` provides common functionality to `RSpec::Core`,
`RSpec::Expectations` and `RSpec::Mocks`. It is considered
suitable for internal use only at this time.

## Installation / Usage

Install one or more of the `RSpec` gems.

Want to run against the `master` branch? You'll need to include the dependent
RSpec repos as well. Add the following to your `Gemfile`:

```ruby
%w[rspec-core rspec-expectations rspec-mocks rspec-support].each do |lib|
  gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

### General: Which Ruby

Check that the Ruby version you are running is one that is supported.
You can see what versions RSpec is tested against by looking at the
[.travis.yml](https://github.com/rspec/rspec-support/blob/v3.2.1/.travis.yml#L16-26)
(noting [allowed failures](https://github.com/rspec/rspec-support/blob/master/.travis.yml#L34-L36))
and the [appveyor.yml](https://github.com/rspec/rspec-support/blob/v3.2.1/appveyor.yml#L32-L34).

### Running tests

`bundle exec rake` locally, and check the CI results in your pull request.

### Caveats: Encodings

Some tests fail if the external/locale/filesystem encoding is ISO-8859-1, which is the default on
some machines, such as the [rake-compiler-dev-box](https://github.com/tjschuck/rake-compiler-dev-box).

The tests on Travis run with certain [ENV variables our suite depends on](http://docs.travis-ci.com/user/ci-environment/):

> LANG=en_US.UTF-8
> LC_ALL=en_US.UTF-8
> JRUBY_OPTS="--server -Dcext.enabled=false -Xcompile.invokedynamic=false"

**Ruby 1.9+ on *nix** uses `LANG`, `LC_ALL` among other variables to set the Encoding.default_external.
The settings above will set it to UTF-8.  Thus, before running tests, you'll want to ensure you or your
login profile have run

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

**Ruby 1.9+ on Windows** likely runs under an Encoding.default_external such as `ibm437`.
You can get the current `codepage` from the command prompt by running `chcp` and
change it to utf8 via `chcp 65001`. See
https://github.com/rspec/rspec-support/pull/151#discussion_r22991439
http://stackoverflow.com/questions/1259084/what-encoding-code-page-is-cmd-exe-using and
https://github.com/ruby/ruby/blob/9fd7afefd04134c98abe594154a527c6cfe2123b/ext/win32ole/win32ole.c#L540
for more information and https://github.com/rspec/rspec-support/pull/151#discussion_r22991439 for
background discussion.

The above platform-specific methods are necessary when running our tests on Ruby 1.8.7.  Otherwise,
we could run our tests commands with `ruby -E UTF-8:UTF-8 -S $spec_command`, which fails on Ruby 1.8.7.

Available **JRUBY** options can be reviewed by running `jruby --properties`.
