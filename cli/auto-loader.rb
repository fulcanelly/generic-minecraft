require 'yaml'
require 'json'
require 'open-uri'
require 'net/http'
require 'cgi'
require 'colored'

module SpigetApi
end

class << SpigetApi
  def get_conn
    uri = URI"https://api.spiget.org/"
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true)
  end

  def make_request(url)
    pp url
    get_conn().request(Net::HTTP::Get.new(url)).body
  end

  def make_json_req(url)
    make_request(url)
      .then do
        JSON.load _1
      end
  end

  def last_version(res)
    make_json_req("https://api.spiget.org/v2/resources/#{res}/versions/latest")
  end

  def get_versions(res)
    make_json_req("https://api.spiget.org/v2/resources/#{res}/versions")
  end

  def download_by_id(res)
    res = make_request("https://api.spiget.org/v2/resources/#{res}/download")
    matched = res.match /https:.*/
    if matched then
      OpenURI.open_uri(matched[0])
    else
      throw "not found"
    end
  end

  def get_details(res_id)
    make_json_req("https://api.spiget.org/v2/resources/#{res_id}")
  end

  def search_by_name(name)
    make_json_req("https://api.spiget.org/v2/search/resources/#{
      CGI.escape(name)
    }?field=name&size=2")
  end
end


#pp SpigetApi.download_by_id(2333333333332)
#flow (validate) -> (load info) -> (load file) -> applly
# ways to supply pluging:
# by name, by spigot id, by direct url
class Plugin
  def validate()
  end

  def load_name
  end

  def load_versions
  end

  #loads plugin to cache
  def load()
  end

  # gives loaction of plugin
  def get_file()
  end
end

config = YAML.load(
  File.read('config.yml')
)

def load_plugins(config)
  config["plugins"].each do |key, entry|
    # find plugin
    plugins = SpigetApi.search_by_name(entry["name"])

    # first match
    plugin = plugins.first
    id = plugin["id"]

    # get latest version
    last = SpigetApi.last_version(id)
    version_name = last["name"]

    # get file name
    name = plugin["name"].split(/\s/).first

    file_name = "out/#{name}-#{version_name}.jar"
    puts file_name.red

    next puts "skip".yellow if File.exist?(file_name)

    Dir.mkdir('out') unless Dir.exist?('out')

    # download
    open(file_name, 'w') do |out|
        file = SpigetApi.download_by_id(last["resource"])
        out.write(file.read)
    end

    puts
end


end

load_plugins(config)
