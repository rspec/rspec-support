module RSpec::Support
  # @api private
  #
  # Replacement for fileutils#mkdir_p because we don't want to require parts
  # of stdlib in RSpec.
  class DirectoryMaker
    # @api private
    #
    # Implements nested directory construction
    def self.mkdir_p(path)
      stack = path.start_with?(File::SEPARATOR) ? File::SEPARATOR : "."
      path.split(File::SEPARATOR).each do |part|
        stack = File.join(stack, part)

        begin
          unless directory_exists?(stack)
            Dir.mkdir(stack)
          end
        rescue Errno::ENOTDIR
          raise Errno::EEXIST.new($!.message)
        end

      end
    end

    private

    def self.directory_exists?(dirname)
      File.exist?(dirname) && File.directory?(dirname)
    end
  end
end
