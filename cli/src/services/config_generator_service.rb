

class ConfigGeneratorService

  def self.plugins_from_file_names(names)
    names.map do plugin_from_file_name(_1) end
  end

  private

  def self.plugin_from_file_name(name)
    name_chunks = name.split(/(\.jar|_|-)/)
    data = SpigetApi.search_by_name(name_chunks.first).first

    if data then
      version = SpigetApi.last_version(data['id'])
      {
        name: data['name'],
        source: :spigot,
        resource_id: version['resource']
      }
    else
      {
        name: name.split('.jar').first,
        source: :unknown
      }
    end
  end

  def self.verify_plugins(plugins)
    plugins.map do |plugin|
      verify_plugin(plugin)
    end.filter(&:itself)
  end

  def self.verify_plugin(plugin)
    if plugin[:source].to_sym == :unknown
      { warn: "Can't load plugin, unknown source" }
    end
  end

  def self.plugin_from_zip_file
    # TODO
  end

end
