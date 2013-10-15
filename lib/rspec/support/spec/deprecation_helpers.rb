module RSpecHelpers
  def expect_deprecation_with_call_site(file, line)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      expect(options[:call_site]).to include([file, line].join(':'))
    end
  end

  def allow_deprecation
    allow(RSpec.configuration.reporter).to receive(:deprecation)
  end

  def expect_warning_without_call_site(expected = //)
    expect(::Kernel).to receive(:warn) do |message|
      expect(message).to match expected
      expect(message).to_not match(/Called from/)
    end
  end

  def expect_warning_with_call_site(file, line, expected = //)
    expect(::Kernel).to receive(:warn) do |message|
      expect(message).to match expected
      expect(message).to match(/Called from #{file}:#{line}/)
    end
  end

  def allow_warning
    allow(::Kernel).to receive(:warn)
  end
end
