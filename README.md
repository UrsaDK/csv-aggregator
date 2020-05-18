# CSV-Aggregator

We need a Ruby program that can take data from the three CSV files included and produce the new CSV or JSON formats by running it like so:

    $ ruby combine.rb --format json journals.csv articles.csv authors.json > full_articles.json
    $ ruby combine.rb --format csv journals.csv articles.csv authors.json > full_articles.csv

## Requirements

  - ruby 2.4+
  - docker (optional)

## How to build the environment?

If you don't have a local development environment, you can easily create it using docker. The following commands are used to bring up the environment and open the shell:

  ```
  docker build --tag csv-combine .
  docker run -it csv-combine
  ```

All tests are executed as part of the build, and the coverage report is generated in `./coverage/index.html`. If need be, you can re-run the tests manually with:

  ```
  docker$ bundle exec rubocop
  docker$ bundle exec rspec
  ```

## How to run the tests locally?

If your environment is already setup for local development, then all the tests can be run locally without docker.

Required gems can be installed with:

  - `bundle install`

Tests are run using:

  - `bundle exec rubocop`
  - `bundle exec rspec`

After running `rspec`, coverage report is available in `./coverage/index.html`.
