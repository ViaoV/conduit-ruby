#require "conduit/version"
require "openssl"
require "base64"
require "net/http"
require "json"
require 'securerandom'
require 'uri'

module Conduit

  class ApiError < StandardError; end

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
      hmac =  OpenSSL::HMAC.digest("sha256", @access_key_secret, data)
      request[:keyName] = @access_key_name
      request[:signature] = Base64.encode64(hmac)
    end

    def request(endpoint, request)
      uri = URI("http://#{@host}/#{endpoint}")
      req = Net::HTTP::Post.new(uri)
      req.content_type = 'application/json'
      sign! request
      req.body = JSON.generate(request)
      res = Net::HTTP.new(uri.hostname, uri.port).start {|h| h.request(req) }
      if res.code == "200"
        return JSON.parse(res.body)
      end
      if res.code == "404"
        raise ApiError, "Endpoint not found"
      end
      if res.code == "400"
        raise ApiError, JSON.parse(res.body)[:error]
      end
      puts res.code
    end

    def register(mailbox_name)
      request "register", {mailbox: mailbox_name}
    end

    def deregister(mailbox_name)
      request "deregister", {mailbox: mailbox_name}
    end

    def get_message()
      request "get", {mailbox: mailbox_name}
    end

    def system_stats()
      request "stats", {}
    end

    def client_stats()
      request "stats/clients", {}
    end

    def list_deployments(opts = {})
      request = {}
      request[:deploymentId] = opts[:id] || ""
      request[:nameSearch] = opts[:name] || ""
      request[:keySearch] = opts[:keyName] || ""
      request[:count] = opts[:count] || 10
      request "deploy/list", request
    end

    def deploy(mailboxes, script, opts = {})
      request = {body: script}
      request[:mailboxes] = mailboxes if mailboxes.is_a Array
      request[:pattern] = mailboxes if mailboxes.is_a String
      request[:deploymentName] = opts[:name] if opts[:name]
      request[:asset] = opts[:asset] if opts[:asset]
      request "put", request
    end

  end

end
