PassSlot Ruby SDK (v.0.1)

[PassSlot](http://www.passslot.com) is a Passbook service that makes Passbook usage easy for everybody. It helps you design and distribute mobile passes to all major mobile platforms.

This repository contains the open source Ruby SDK that allows you to
access PassSlot from your Ruby app. Except as otherwise noted,
the PassSlot Ruby SDK is licensed under the Apache Licence, Version 2.0
(http://www.apache.org/licenses/LICENSE-2.0.html).

## Installation

Add this line to your application's Gemfile:

    gem 'PassSlot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install PassSlot

## Usage

The [example.rb](example/example.rb) is a good place to start. The minimal you'll need to
have is:
```ruby
require 'PassSlot'

engine = PassSlot.start('<YOUR APP KEY>')
pass = engine.create_pass_from_template(<Template ID>)
puts pass.url
```
(Assuming you have already setup a template that does not require any values)

## Contributing

1. Fork it ( https://github.com/passslot/passslot-ruby-sdk/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
