# encoding: utf-8

begin
  require 'lz4-ruby'
rescue LoadError => e
  raise LoadError, %[LZ4 support requires the "lz4-ruby" gem: #{e.message}], e.backtrace
end

module Cql
  module Compression
    # A compressor that uses the LZ4 compression library.
    #
    # @note This compressor requires the [lz4-ruby](http://rubygems.org/gems/lz4-ruby)
    #   gem (v0.3.2 or later required).
    class Lz4Compressor
      # @return [String]
      attr_reader :algorithm

      # @param [Integer] min_size (64) Don't compress frames smaller than
      #   this size (see {#compress?}).
      def initialize(min_size=64)
        @algorithm = 'lz4'.freeze
        @min_size = min_size
      end

      # @return [true, false] will return false for frames smaller than the
      #   `min_size` given to the constructor.
      def compress?(str)
        str.bytesize > @min_size
      end

      def compress(str)
        [str.bytesize, LZ4::Raw.compress(str.to_s).first].pack(BUFFER_FORMAT)
      end

      def decompress(str)
        decompressed_size, compressed_data = str.to_s.unpack(BUFFER_FORMAT)
        LZ4::Raw.decompress(compressed_data, decompressed_size).first
      end

      private

      BUFFER_FORMAT = 'Na*'.freeze
    end
  end
end