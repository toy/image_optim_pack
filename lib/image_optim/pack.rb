require 'fspath'
require 'image_optim/bin_resolver/bin'

class ImageOptim
  # Handle selection of directory with binaries most suitable for current
  # operating system and architecture
  module Pack
    # Path to binary, last two parts are expect to be os/arch
    class Path
      attr_reader :path, :os, :arch

      def initialize(path)
        @path = FSPath(path)
        @os = @path.dirname.basename.to_s
        @arch = @path.basename.to_s
      end

      def to_s
        path.to_s
      end

      # Cached array of BinResolver::Bin instances for each bin
      def bins
        @bins ||= bin_paths.map do |bin_path|
          BinResolver::Bin.new(bin_path.basename.to_s, bin_path.to_s)
        end
      end

    private

      def bin_paths
        path.children.reject{ |child| child.basename.to_s =~ /^lib/ }
      end
    end

    # downcased `uname -s`
    OS = `uname -s`.strip.downcase

    # downcased `uname -m`
    ARCH = `uname -m`.strip.downcase

    # Path to vendor at root of image_optim_pack
    VENDOR_PATH = FSPath('../../../vendor').expand_path(__FILE__)

    # List of paths
    PACK_PATHS = VENDOR_PATH.glob('*/*').map{ |path| Path.new(path) }

    class << self
      # Return path to directory with binaries
      # Yields debug messages if block given
      def path
        ordered_by_os_arch_match.find do |path|
          yield "image_optim_pack: #{debug_message(path)}" if block_given?
          path.bins.all?(&:version)
        end
      end

    private

      # Order by match of os and architecture
      def ordered_by_os_arch_match
        PACK_PATHS.sort_by do |path|
          [path.os == OS ? 0 : 1, path.arch == ARCH ? 0 : 1]
        end
      end

      # Messages based on success of getting versions of bins
      def debug_message(path)
        bins = path.bins
        case
        when bins.all?(&:version)
          "all bins from #{path} worked"
        when bins.any?(&:version)
          names = bins.reject(&:version).map(&:name)
          "#{names.join(', ')} from #{path} failed"
        else
          "all bins from #{path} failed"
        end
      end
    end
  end
end
