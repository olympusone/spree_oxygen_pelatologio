# Spree Oxygen Pelatologio

This is an Oxygen Pelatologio extension for [Spree Commerce](https://spreecommerce.org), an open‑source e-commerce platform built with Ruby on Rails. It adds the ability to sync Oxygen Pelatologio data.

[![Gem Version](https://badge.fury.io/rb/spree_oxygen_pelatologio.svg)](https://badge.fury.io/rb/spree_oxygen_pelatologio)

## Installation

1. Add this extension to your Gemfile with this line:

    ```bash
    bundle add spree_oxygen_pelatologio
    ```

## Developing

1. Create a dummy app

    ```bash
    bundle update
    bundle exec rake test_app
    ```

2. Add your new code

3. Run tests

    ```bash
    bundle exec rspec
    ```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_oxygen_pelatologio/factories'
```

## Releasing a new version

```bash
bundle exec gem bump -p -t
bundle exec gem release
```

For more options please see [gem-release README](https://github.com/svenfuchs/gem-release)

## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

Copyright (c) 2026 OlympusOne, released under the AGPL-3.0 or later.
