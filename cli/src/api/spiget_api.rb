require 'yaml'
require 'json'
require 'open-uri'
require 'net/http'
require 'cgi'
require 'colored'



module SpigetApi

  def self.last_version(res)
    make_json_req("https://api.spiget.org/v2/resources/#{res}/versions/latest")
  end

  def self.get_versions(res)
    make_json_req("https://api.spiget.org/v2/resources/#{res}/versions")
  end

  def self.download_by_resource_id(res)
    res = make_request("https://api.spiget.org/v2/resources/#{res}/download")
    matched = res.match /https:.*/
    if matched then
      OpenURI.open_uri(matched[0], progress_proc: AnimationsService.loading_proc)
    else
      throw "not found"
    end
  end

  def self.get_details(res_id)
    make_json_req("https://api.spiget.org/v2/resources/#{res_id}")
  end

  def self.search_by_name(name, limit: 10, sort_by: '-rating')
    make_json_req("https://api.spiget.org/v2/search/resources/#{
      CGI.escape(name)
    }?field=name&size=#{CGI.escape(limit.to_s)}&sort=#{CGI.escape(sort_by)}")
  end

  def self.get_author_details(author_id)
    make_json_req("https://api.spiget.org/v2/authors/#{ CGI.escape(author_id.to_s)}")
  end

  private

  def self.get_conn
    uri = URI"https://api.spiget.org/"
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true)
  end

  def self.make_request(url)
    pp url
    get_conn().request(Net::HTTP::Get.new(url)).body
  end

  def self.make_json_req(url)
    make_request(url)
      .then do
      JSON.load _1
    end
  end

end
