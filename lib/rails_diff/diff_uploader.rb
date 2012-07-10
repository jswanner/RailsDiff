# encoding: utf-8

require 'json'
require 'net/http'
require 'uri'

module RailsDiff
  class DiffUploader < Struct.new(:url, :diffs)
    def upload
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = {diffs: diffs}.to_json
      request["Content-Type"] = 'application/json'
      http.request(request)
    end

    def uri
      @uri ||= URI.parse url
    end
  end
end
