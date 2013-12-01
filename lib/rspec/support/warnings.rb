module RSpec

  unless respond_to?(:deprecate)

    # @private
    #
    # Used internally to print deprecation warnings
    # when rspec-core isn't loaded
    def self.deprecate(deprecated, options = {})
      warn_with "DEPRECATION: #{deprecated} is deprecated.", options
    end
  end

  unless respond_to?(:warn_deprecation)

    # @private
    #
    # Used internally to print deprecation warnings
    # when rspec-core isn't loaded
    def self.warn_deprecation(message)
      warn_with "DEPRECATION: \n #{message}"
    end
  end

  # @private
  #
  # Used internally to print warnings
  def self.warning(text, options={})
    warn_with "WARNING: #{text}.", options
  end

  # @private
  #
  # Used internally to print longer warnings
  def self.warn_with(message, options = {})
    call_site = options.fetch(:call_site) { CallerFilter.first_non_rspec_line }
    message << " Use #{options[:replacement]} instead." if options[:replacement]
    message << " Called from #{call_site}." if call_site
    ::Kernel.warn message
  end

end
