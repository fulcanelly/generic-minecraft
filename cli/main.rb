#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"
require "yaml"
require './all'

module ServerSettuper
  CONFIG_FILE_NAME = 'setup-config.yml'

  module CLI
    module Commands

      module Plugins
        class Load < Dry::CLI::Command
          desc 'Loads specified versions of plugins'

          option :path, type: :string, required: false, default: '.', desc: 'Path to server'

          def call(path:, **)
            config_path = path + '/' + CONFIG_FILE_NAME
            plugins_folder = path + '/plugins'

            puts 'Loading config'.yellow

            config = YAML.load(File.read(config_path)).deep_symbolize_keys

            plugins = config[:plugins]

            ConfigGeneratorService.verify_plugins(plugins).each do |warn|
              puts warn[:warn].red + ': ' + warn[:name]
            end

            plugins = plugins.filter do _1[:source].to_sym != :unknown end

            if plugins.empty?
              puts 'No valid plugin, stopping'.yellow
              return
            end

            puts 'Loading resources'.green
            plugins.each do |plugin|
              case plugin[:source].to_sym
              when :spigot
                file = SpigetApi.download_by_resource_id(plugin[:resource_id])
                         .read
                plugin_location = plugins_folder + '/' + plugin[:location]

                File.write(plugin_location, file)
                puts
                puts "Saved plugin at #{plugin_location}".yellow

              else
                puts "unknown plugin source #{plugin[:source]}".red
              end
            end
            puts "Done.".green

          end
        end

        class Update < Dry::CLI::Command
          desc '- Updates all plugins to latest versions'

          def call(**)
            nil
          end
        end
      end

      module Server
        class Load < Dry::CLI::Command
          desc 'Loads specified version of server'

          option :path, type: :string, required: false, default: '.', desc: 'Path to server'

          def call(path:, **)
            config_path = path + '/' + CONFIG_FILE_NAME
            config = YAML.load(File.read(config_path)).deep_symbolize_keys

            puts 'Loaded config'.yellow

            server = config[:server]

            case server[:type]
            when 'purpur'
              server_location = path + '/' + server[:location]

              File.write(server_location, PurpurApi.download_latest_build(server[:version]).read)
              puts
              puts "Server saved at #{server_location} location".green
            else
              puts 'Unknown server type, stopping'.red
            end

          end
        end

        class Update < Dry::CLI::Command
          desc '- Update server to latest version'

          def call(**)
            nil
          end
        end
      end

      class Init < Dry::CLI::Command


        desc "Init server setupper config"

        option :path, type: :string, required: false, default: '.', desc: 'Path to server'
        option :builder, type: :boolean, required: false, default: false, desc: 'Run with prompt'
        option :override, type: :boolean, required: false, default: false, desc: 'Override existing config'

        def call(path:, **)
          config = {
            version: '1.0.0'
          }

          config[:plugins] = []

          plugins_folder = path + '/plugins'

          if Dir.exist? plugins_folder
            puts 'Found plugin folder, gathering info'.yellow

            jar_files = Dir.entries(plugins_folder)
              .filter do
                _1.end_with? '.jar'
              end
            config[:plugins] = ConfigGeneratorService.plugins_from_file_names(jar_files)
          end

          puts 'Getting latest purpur version'.yellow
          versions = PurpurApi.list_versions

          config['server'] = {
            type: :purpur,
            version: versions['versions'].last,
            location: 'server.jar'
          }

          config = config.deep_stringify_keys.deep_stringify_sym_values
          yaml = YAML.dump(config)

          config_path = path + '/' + CONFIG_FILE_NAME
          File.write(config_path, yaml, mode: 'w')

          puts "Generated config saved to #{config_path}:".yellow
          puts yaml.red
        end
      end

      extend Dry::CLI::Registry

      register 'init', Init

      register 'plugins' do |prefix|
        prefix.register 'load', Plugins::Load
        prefix.register 'update', nil
      end

      register 'server' do |prefix|
        prefix.register 'load', Server::Load
        prefix.register 'update', nil

      end
    end
  end
end

Dry::CLI.new(ServerSettuper::CLI::Commands).call