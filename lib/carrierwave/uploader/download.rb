# encoding: utf-8

require 'open-uri'
require 'mime/types'

module CarrierWave
  module Uploader
    module Download
      extend ActiveSupport::Concern

      include CarrierWave::Uploader::Callbacks
      include CarrierWave::Uploader::Configuration
      include CarrierWave::Uploader::Cache

      class RemoteFile
        def initialize(uri, config)
          @uri = uri
          @config = config
        end

        def original_filename
          raw = File.basename(file.base_uri.path)
          raw += get_extension_by_mime_type if @config.set_file_extension_by_mime_type
          raw
        end

        def respond_to?(*args)
          super or file.respond_to?(*args)
        end

        def http?
          @uri.scheme =~ /^https?$/
        end

        def get_extension_by_mime_type
          ext  = File.extname(file.base_uri.path).gsub(/^\./, "")
          mime = file.content_type

          exts  = MIME::Types[mime] || []
          found = false
          exts.each do |mime_type|
            if (mime_type && mime_type.extensions.include?(ext.downcase))
              found = true
            end
          end

          if !found && exts && exts[0] && exts[0].extensions
            "." + exts[0].extensions[0]
          else
            ""
          end
        end
      private

        def file
          if @file.blank?
            @file = Kernel.open(@uri.to_s)
            @file = @file.is_a?(String) ? StringIO.new(@file) : @file
          end
          @file
        end

        def method_missing(*args, &block)
          file.send(*args, &block)
        end
      end

      ##
      # Caches the file by downloading it from the given URL.
      #
      # === Parameters
      #
      # [url (String)] The URL where the remote file is stored
      #
      def download!(uri)
        unless uri.blank?
          processed_uri = process_uri(uri)
          file = RemoteFile.new(processed_uri, self)
          raise CarrierWave::DownloadError, "trying to download a file which is not served over HTTP" unless file.http?
          cache!(file)
        end
      end

      ##
      # Processes the given URL by parsing and escaping it. Public to allow overriding.
      #
      # === Parameters
      #
      # [url (String)] The URL where the remote file is stored
      #
      def process_uri(uri)
        URI.parse(URI.escape(URI.unescape(uri)))
      end

    end # Download
  end # Uploader
end # CarrierWave
