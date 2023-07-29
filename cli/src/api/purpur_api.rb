require 'json'
require 'net/http'
require 'open-uri'

module PurpurApi
  PURPUR_API_BASE_URL = "https://api.purpurmc.org/v2/purpur/"

  def self.get_conn
    uri = URI(PURPUR_API_BASE_URL)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true)
  end

  def self.make_request(url)
    pp url
    get_conn().request(Net::HTTP::Get.new(url)).body
  end

  def self.make_json_req(url)
    make_request(url)
      .then { |response| JSON.parse(response) }
  end

  def self.list_versions
    make_json_req(PURPUR_API_BASE_URL)
  end

  def self.list_builds_for_version(version)
    make_json_req("#{PURPUR_API_BASE_URL}#{version}")
  end

  def self.download_build(version, build)
    OpenURI.open_uri("#{PURPUR_API_BASE_URL}#{version}/#{build}/download")
  end

  def self.download_latest_build(version)
    OpenURI.open_uri("#{PURPUR_API_BASE_URL}#{version}/latest/download",
        content_length_proc: ->(total) {

            # if total && total > 0
            #   @total_size = total
            #   @loaded_size = 0
            #   puts "Total size: #{@total_size} bytes"
            # end
          },
          progress_proc: ->(size) {
            state_index += 1
            load_elements = ["\\", "|", "/", "-"]
            print "\rLoading: #{load_elements[state_index % load_elements.size]}%"

            # puts @loaded_size
            # puts @total_size
            # @loaded_size += size
            # progress = ((@loaded_size.to_f / @total_size) * 100).round(2)
            # print "\rLoading: #{progress}%"
          })
  end
end