require 'yaml'
require 'json'
require 'open-uri'
require 'net/http'
require 'cgi'

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
		"https://api.spiget.org/v2/resources/8/versions/latest"
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


	def search_by_name(name)	 
	 	make_json_req("https://api.spiget.org/v2/search/resources/#{
	 		CGI.escape(name)
		}?field=name&size=2")
	end

end


#pp SpigetApi.download_by_id(2333333333332)

# ways to supply pluging:
# by name, by spigot id, by direct url
class Plugin 
	
	#should raise exception or load plugin from spigot 
	def self::parse(entry)
		if entry["name"] then 
			plugin = SpigetApi.search_by_name(entry["name"])
			pp plugin
			plugin = plugin.first
			#pp plugin["File"]["type"]
			if plugin then 
				pp plugin["name"]
			else 
				pp entry 
				puts "!!!\n"
			end

		else 
			throw "bad plugin config"
		end


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

def parse_plugins(config)
	config["plugins"].each do |key, entry|
		Plugin.parse(entry)
	
	end


end

pp config
parse_plugins(config)