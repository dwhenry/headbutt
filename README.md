# Headbutt

This gem has been built as a drop in replacement for [Sidekiq Gem](https://github.com/mperham/sidekiq).
It has been built using the sidekiq core classes (why reinvent the wheel) with some modification.

Headbutt should give you all the functionality you are used to from sidekiq, but using RabbitMQ
as the backend queuing system.


## What Next

Fully extract RabbitMQ related code so that alternative queuing systems can be swapped in.

Add message bus support using topic exchanges and routing keys. 
 
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'headbutt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install headbutt

## Usage

As the gem is heavily based in Sidekiq I would recommend reading its guide: [Getting Started wiki page](https://github.com/mperham/sidekiq/wiki/Getting-Started) 
and follow the simple setup process. I may look to write my own guide once I have everything working.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dwhenry/headbutt. This project is intended 
to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

Please see [LICENSE](https://github.com/mperham/sidekiq/blob/master/LICENSE) for licensing details.


## Authors

* David Henry
* Matt [@lamp](https://github.com/lamp)
* With thanks to Mike Perham for his excelent work on sidekiq, [@mperham](https://twitter.com/mperham) / [@sidekiq](https://twitter.com/sidekiq), [http://www.mikeperham.com](http://www.mikeperham.com) / [http://www.contribsys.com](http://www.contribsys.com)
