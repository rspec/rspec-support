# This file was generated on 2020-09-28T21:53:54+02:00 from the rspec-dev repo.
# DO NOT modify it by hand as your changes will get lost the next time it is generated.

function is_mri {
  # RUBY_ENGINE only returns 'ruby' on MRI.
  if ruby -e "exit(RUBY_ENGINE == 'ruby')"; then
    return 0
  else
    return 1
  fi;
}

function is_jruby {
  # RUBY_ENGINE only returns 'java' on JRuby. - does it? How about TruffleRuby?
  if ruby -e "exit(defined?(RUBY_PLATFORM) && RUBY_PLATFORM == 'java')"; then
    return 0
  else
    return 1
  fi;
}

function is_ruby_25_plus {
  if ruby -e "exit(RUBY_VERSION.to_f >= 2.5)"; then
    return 0
  else
    return 1
  fi
}

function rspec_rails_compatible {
  if is_ruby_25_plus; then
    return 0
  else
    return 1
  fi
}

function additional_specs_available {
  type run_additional_specs > /dev/null 2>&1
  return $?
}

function documentation_enforced {
  if [ -x ./bin/yard ]; then
    return 0
  else
    return 1
  fi
}

function style_and_lint_enforced {
 if [ -x ./bin/rubocop ]; then
   return 0
 else
   return 1
 fi
}
