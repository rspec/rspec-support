module RSpec
  module Support
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
            Dir.mkdir(stack) unless directory_exists?(stack)
          rescue Errno::ENOTDIR => e
            raise Errno::EEXIST, e.message
          end
        end
      end

      def self.directory_exists?(dirname)
        File.exist?(dirname) && File.directory?(dirname)
      end
      private_class_method :directory_exists?
    end
  end
end
