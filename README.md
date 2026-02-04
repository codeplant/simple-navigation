# Simple Navigation

[![Gem Version](https://badge.fury.io/rb/simple-navigation.png)](http://badge.fury.io/rb/simple-navigation)
[![Build Status](https://secure.travis-ci.org/codeplant/simple-navigation.png?branch=master)](http://travis-ci.org/codeplant/simple-navigation)
[![Code Climate](https://codeclimate.com/github/codeplant/simple-navigation.png)](https://codeclimate.com/github/codeplant/simple-navigation)
[![Coverage Status](https://coveralls.io/repos/codeplant/simple-navigation/badge.png)](https://coveralls.io/r/codeplant/simple-navigation)

Simple Navigation is a ruby library for creating navigations (with multiple levels) for your Rails, Sinatra or Padrino applications. It runs with all ruby versions (including ruby 2.x).

## Documentation

For the complete documentation, take a look at the [project's wiki](https://github.com/codeplant/simple-navigation/wiki).

## RDoc

You can consult the project's RDoc on [RubyDoc.info](http://rubydoc.info/github/codeplant/simple-navigation/frames).

If you need to generate the RDoc files locally, check out the repository and simply call the `rake rdoc` in the project's folder.

##  Demo

Demo source code is [available on Github](http://github.com/codeplant/simple-navigation-demo).

## Feedback and Questions

Don't hesitate to come talk on the [project's group](http://groups.google.com/group/simple-navigation).

## Contributing

Fork, fix, then send a Pull Request.

To run the test suite locally against all supported frameworks:

```sh
bundle install
bin/appraisal bundle install
bin/appraisal rspec
bin/appraisal rspec ./spec/requests/users_spec.rb
```

To target the test suite against one framework:

```sh
bin/appraisal rails_8.1 rspec
bin/appraisal rails_8.1 rspec ./spec/requests/users_spec.rb
```

## License

Copyright (c) 2026 codeplant GmbH, released under the MIT license
