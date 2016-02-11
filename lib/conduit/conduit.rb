#require "conduit/version"
require "openssl"
require "base64"
require "net/http"
require "json"
require 'securerandom'
require 'uri'

module Conduit

  class Client
    attr_accessor :host, :access_key_name, :access_key_secret
    def initialize(host, key_name, key_secret)
      @host = host
      @access_key_name = key_name
      @access_key_secret = key_secret
    end

    def sign!(request)
      request[:requestTime] = Time.new.strftime("%Y-%m-%dT%H:%M:%S%:z")
      request[:token] = SecureRandom.uuid
      data = request[:token] + request[:requestTime]
      puts data
      hmac =  OpenSSL::HMAC.digest("sha256", @access_key_secret, data)
      request[:keyName] = @access_key_name
      puts hmac.each_byte.map { |b| b.to_s(16) }.join
      request[:signature] = Base64.encode64(hmac)
    end

    def request(endpoint, request)
      uri = URI("http://#{@host}/#{endpoint}")
      req = Net::HTTP::Post.new(uri)
      req.content_type = 'application/json'
      sign! request
      puts JSON.generate(request)
      req.body = JSON.generate(request)
      res = Net::HTTP.new(uri.hostname, uri.port).start {|h| h.request(req) }
      JSON.parse(res.body)
    end

    def register(mailbox_name)
      request "get", {mailbox: mailbox_name}
    end

    def get_message()
      request "register", {mailbox: mailbox_name}
    end
  end

end
