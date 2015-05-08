# Methods for getting and setting device details

require 'json'

module AppleDEPClient
  module Device
    FETCH_PATH = "/server/devices"
    FETCH_LIMIT = 1000 # must be between 100 and 1000
    DISOWN_PATH = "/devices/disown"
    DETAILS_PATH = "/devices/details"

    def self.fetch
      response = {'cursor'=>nil, 'more_to_follow'=> 'true' }
      while response['more_to_follow'] == 'true'
        response = make_fetch_request response['cursor']
        response['devices'].each do |device|
          yield device
        end
      end
      return response['cursor']
    end

    def self.make_fetch_request cursor
      body = fetch_body(cursor)
      AppleDEPClient::Request.make_request(AppleDEPClient::Request.make_url(FETCH_PATH), :post, body)
    end

    def self.fetch_body cursor
      body = {"limit" => FETCH_LIMIT}
      if cursor
        body["cursor"] = cursor
      end
      JSON.dump body
    end

    def self.sync
      raise NotImplementedError
    end

    def self.details(devices)
      body = devices
      body = JSON.dump body
      response = AppleDEPClient::Request.make_request(AppleDEPClient::Request.make_url(DETAILS_PATH), :post, body)
      response['devices']
    end

    # Accepts an array of device ID strings
    def self.disown(devices)
      body = {'devices' => devices}
      body = JSON.dump body
      response = AppleDEPClient::Request.make_request(AppleDEPClient::Request.make_url(DISOWN_PATH), :post, body)
      response['devices']
    end
  end
end
