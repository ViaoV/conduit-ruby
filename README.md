# Ruby SDK for Conduit

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'conduit-sdk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conduit-sdk

## Usage

### Create a client

To create a client you will need an administrative access key and key name. These can be generated from the conduit CLI on the server.

```ruby
    Conduit::Client.new(hostAddress, keyName, keySecret)
```

### Register a mailbox

```ruby
    client = Conduit::Client.new(hostAddress, keyName, keySecret)
    client.register("my.mailbox.name")
```

This will register a new mailbox with the server, it will raise Conduit::APIError on failure.

### Deregister a mailbox

```ruby
    client = Conduit::Client.new(hostAddress, keyName, keySecret)
    client.deregister("my.mailbox.name")
```

This will delete a mailbox and purge its messages, it will raise Conduit::APIError on failure.

### Getting system statistics

The system_stats method will return a number of metrics.

```ruby
    client = Conduit::Client.new(hostAddress, keyName, keySecret)
    stats = client.system.stats
    puts stats[:field]
```

#### Fields

* _totalMailboxes_ - The total number of mailboxes registered in the system.
* _messageCount_ - The total number of messages that have passed through the system.
* _pendingMessages_ - The current number of messages waiting to be delivered.
* _connectedClients_ - The current number of clients that are connected to the server.
* _dbVersion_ - The server database version.
* _threads_ - The number of active threads the server is using.
* _cpuCount_ - The number of CPUs available to the server.
* _memory_ - The total allocated memory the server is currently using.
* _filesCount_ - The total number of script assets stored on the server.
* _filesSize_ - The size on disk of all script assets the server is holding.

### Getting client statistics

The system_stats method will return a number of metrics.

```ruby
    client = Conduit::Client.new(hostAddress, keyName, keySecret)
    stats = client.client_stats.clients.each do |client|
        puts client[:field]
    end
```

#### Fields

* _version_ - The client's last reported Conduit version.
* _online_ - True if the client is currently connected.
* _mailbox_ - The client's mailbox name.
* _lastSeenAt_ - A date/time string when the client last checked for messages.
* _host_ - The IP address of the client.

### Listing deployments

```ruby
    client = Conduit::Client.new(hostAddress, keyName, keySecret)
    client.list_deployments(_options_).deployments.each do |d|
        puts d[:field]
    end
```

#### Options

* _deploymentId_ - The name of a specific deployment. If specified the response will contain a :responses array which will contain information on the client responses to the deployment.
* _nameSearch_ - A glob pattern for searching deployment names (ex: "Upgrade*").
* _keySearch_ - A glob pattern for searching for deployments based on the keyname that deployed them (ex: ops.*).
* _count_ - The number of deployments to return.

#### Fields

* _name_ - The name of the deployment
* _createdAt_ A date string representing the creation time of the deployment.
* _pendignMessages_ - The number of messages that have not been picked up.
* _totalMessages_ - The total number of messages deployed.
* _responseCount_ - The number of responses received
* _responses_ - An array of hashses for the client responses to the deployments. Each has has the follwoing keys: Mailbox, Response, RespondedAt, and IsError. This value is only present if a specific deploymentId was specifeid.
* _deployedBy_ - The access key name used to create the deployment.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/conduit-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
