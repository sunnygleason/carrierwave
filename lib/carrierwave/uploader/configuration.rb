module CarrierWave

  module Uploader
    module Configuration
      extend ActiveSupport::Concern

      included do
        class_attribute :_storage, :instance_writer => false

        add_config :root
        add_config :base_path
        add_config :permissions
        add_config :storage_engines
        add_config :s3_access_policy
        add_config :s3_bucket
        add_config :s3_access_key_id
        add_config :s3_secret_access_key
        add_config :s3_cnamed
        add_config :s3_headers
        add_config :s3_region
        add_config :s3_use_ssl
        add_config :s3_authentication_timeout
        add_config :cloud_files_username
        add_config :cloud_files_api_key
        add_config :cloud_files_container
        add_config :cloud_files_cdn_host
        add_config :cloud_files_auth_url
        add_config :cloud_files_snet
        add_config :grid_fs_connection
        add_config :grid_fs_database
        add_config :grid_fs_host
        add_config :grid_fs_port
        add_config :grid_fs_username
        add_config :grid_fs_password
        add_config :grid_fs_access_url
        add_config :store_dir
        add_config :cache_dir
        add_config :enable_processing
        add_config :ensure_multipart_form
        add_config :delete_tmp_file_after_storage
        add_config :move_to_cache
        add_config :move_to_store
        add_config :remove_previously_stored_files_after_update
        add_config :set_file_extension_by_mime_type

        # fog
        add_config :fog_attributes
        add_config :fog_credentials
        add_config :fog_directory
        add_config :fog_host
        add_config :fog_public
        add_config :fog_authenticated_url_expiration

        # Mounting
        add_config :ignore_integrity_errors
        add_config :ignore_processing_errors
        add_config :validate_integrity
        add_config :validate_processing
        add_config :mount_on

        # set default values
        reset_config
      end

      module ClassMethods

        ##
        # Sets the storage engine to be used when storing files with this uploader.
        # Can be any class that implements a #store!(CarrierWave::SanitizedFile) and a #retrieve!
        # method. See lib/carrierwave/storage/file.rb for an example. Storage engines should
        # be added to CarrierWave::Uploader::Base.storage_engines so they can be referred
        # to by a symbol, which should be more convenient
        #
        # If no argument is given, it will simply return the currently used storage engine.
        #
        # === Parameters
        #
        # [storage (Symbol, Class)] The storage engine to use for this uploader
        #
        # === Returns
        #
        # [Class] the storage engine to be used with this uploader
        #
        # === Examples
        #
        #     storage :file
        #     storage CarrierWave::Storage::File
        #     storage MyCustomStorageEngine
        #
        def storage(storage = nil)
          if storage
            self._storage = storage.is_a?(Symbol) ? eval(storage_engines[storage]) : storage
          end
          _storage
        end
        alias_method :storage=, :storage

        def add_config(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{name}(value=nil)
              @#{name} = value if value
              return @#{name} if self.object_id == #{self.object_id} || defined?(@#{name})
              name = superclass.#{name}
              return nil if name.nil? && !instance_variable_defined?("@#{name}")
              @#{name} = name && !name.is_a?(Module) && !name.is_a?(Symbol) && !name.is_a?(Numeric) && !name.is_a?(TrueClass) && !name.is_a?(FalseClass) ? name.dup : name
            end

            def self.#{name}=(value)
              @#{name} = value
            end

            def #{name}
              value = self.class.#{name}
              value.instance_of?(Proc) ? value.call : value
            end
          RUBY
        end

        def configure
          yield self
        end

        ##
        # sets configuration back to default
        #
        def reset_config
          configure do |config|
            config.permissions = 0644
            config.storage_engines = {
              :file => "CarrierWave::Storage::File",
              :fog => "CarrierWave::Storage::Fog",
              :s3 => "CarrierWave::Storage::S3",
              :grid_fs => "CarrierWave::Storage::GridFS",
              :right_s3 => "CarrierWave::Storage::RightS3",
              :cloud_files => "CarrierWave::Storage::CloudFiles"
            }
            config.storage = :file
            config.s3_headers = {}
            config.s3_access_policy = :public_read
            config.s3_region = 'us-east-1'
            config.s3_authentication_timeout = 600
            config.grid_fs_database = 'carrierwave'
            config.grid_fs_host = 'localhost'
            config.grid_fs_port = 27017
            config.fog_attributes = {}
            config.fog_credentials = {}
            config.fog_public = true
            config.fog_authenticated_url_expiration = 600
            config.store_dir = 'uploads'
            config.cache_dir = 'uploads/tmp'
            config.delete_tmp_file_after_storage = true
            config.move_to_cache = false
            config.move_to_store = false
            config.remove_previously_stored_files_after_update = true
            config.set_file_extension_by_mime_type = true
            config.ignore_integrity_errors = true
            config.ignore_processing_errors = true
            config.validate_integrity = true
            config.validate_processing = true
            config.root = lambda { CarrierWave.root }
            config.base_path = CarrierWave.base_path
            config.enable_processing = true
            config.ensure_multipart_form = true
          end
        end
      end

    end
  end
end

