# frozen_string_literal: true

# The connection object will be used to talk to the TPT API
class TPT
  CONTENT_TYPE = 'application/json'

  class << self
    attr_accessor :connection

    def make_api_call(security_token, url, method, payload = nil)
      connection.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = CONTENT_TYPE unless method == :get
        req.headers['Authorization'] = security_token
        req.body = payload.to_json unless payload.nil?
      end
    end
  end
end
