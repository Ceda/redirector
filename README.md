# Redirector

[![Code Climate](https://codeclimate.com/github/vigetlabs/redirector.png)](https://codeclimate.com/github/vigetlabs/redirector) [![Build Status](https://travis-ci.org/vigetlabs/redirector.png?branch=master)](https://travis-ci.org/vigetlabs/redirector) [![Coverage Status](https://coveralls.io/repos/vigetlabs/redirector/badge.png?branch=master)](https://coveralls.io/r/vigetlabs/redirector?branch=master) [![Gem Version](https://badge.fury.io/rb/redirector.png)](http://badge.fury.io/rb/redirector)


Redirector is a Rails engine that adds a piece of middleware to the top of your middleware stack that looks for redirect rules stored in your database and redirects you accordingly.

## Install

1. Add this to your Gemfile and then `bundle install`:

    ```ruby  
    gem 'redirector'
    ```

2. `$ rake redirector_engine:install:migrations`
3. `$ rake db:migrate`
4. Create an interface for admins to manage the redirect rules.


### Config options

`include_query_in_source`: If you want your redirect rules to also match against the query string as well as the path then you need to set this to `true` (the default is `false`).

`silence_sql_logs`: This option silences the logging of Redirector related SQL queries in your log file.

`preserve_query`: Pass the query string parameters through from the source to the target URL.

`use_environment_variables`: This options disable querying to request_environment_rules table.

`blacklisted_extensions`: Skip queries for request_path with extension ['.js', '.css', '.jpg', '.png', '.woff', '.ico']

You can set these inside your configuration in `config/application.rb` of your Rails application like so:

```ruby
module MyApplication
  class Application < Rails::Application
    # ...

    config.redirector.include_query_in_source = true
    config.redirector.silence_sql_logs = true
  end
end
```

## Redirect Rule definitions

Redirect rules have 3 parts:

1. A Source
2. A Destination
3. Request environment conditions

The source defines how to match the incoming request path and the destination is where to send the visitor if the match is made. A source can be a strict string equality match or it can be a regular expression that is matched. If a regular expression is used and it uses groupings, you can reference those groupings inside of the destination. For instance a regex like `/my_custom_path\/([0-9]+)/` could use that grouping in the destination like this `"/my_destination/$1"`. So, if the request path was `"/my_custom_path/10"` then the destination for that rule would be `"/my_destination/10"`.

Redirect rules can also have further Rack/HTTP environment (mainly HTTP headers) conditions via RequestEnvironmentRules. These define a key in the rack environment passed into the middleware and a value match you require for the redirect rule it's tied too. Similar to the redirect rules these RequestEnvironmentRules can be string matches or regex matches. A redirect rule can have as many of these environment rules as you need.

When using regex matching on either a redirect rule source or a request environment rule environment value you can specify if you want the matching to be case sensitive or case insensitive with a boolean column that's on the table.

### Schema Definition

Here's the schema definition used for the two tables:

```ruby
create_table "redirect_rules", :force => true do |t|
  t.string   "source",                                      :null => false # Matched against the request path
  t.boolean  "source_is_regex",          :default => false, :null => false # Is the source a regular expression or not
  t.boolean  "source_is_case_sensitive", :default => false, :null => false # Is the source regex cas sensitive or not
  t.string   "destination",                                 :null => false
  t.boolean  "active",                   :default => false                 # Should this rule be applied or not
  t.datetime "created_at",                                  :null => false
  t.datetime "updated_at",                                  :null => false
end

create_table "request_environment_rules", :force => true do |t|
  t.integer  "redirect_rule_id",                                       :null => false
  t.string   "environment_key_name",                                   :null => false # Name of the enviornment key (e.g. "QUERY_STRING", "HTTP_HOST")
  t.string   "environment_value",                                      :null => false # What to match the value of the specified environment attribute against
  t.boolean  "environment_value_is_regex",          :default => false, :null => false # Is the value match a regex or not
  t.boolean  "environment_value_is_case_sensitive", :default => true,  :null => false # is the value regex case sensitive or not
  t.datetime "created_at",                                             :null => false
  t.datetime "updated_at",                                             :null => false
end
```

## Databases supported

* MySQL
* PostgreSQL

If you require support for another database, the only thing that needs to be added is a definition for a SQL regular expression conditional (see `app/models/redirect_rule.rb`). If you create a pull request that adds support for another database, it will most likely be merged in.

## Contributing to Redirector

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
  * We're using [Appraisal](https://github.com/thoughtbot/appraisal) to test against different Rails versions.
  * In order to run the tests you'll need to do the following:
    1. `cp spec/dummy/config/database.yml.example spec/dummy/config/database.yml`
    2. modify that `spec/dummy/config/database.yml` with your mysql configuration details
    3. run `appraisal install` (should only need to do this once)
    4. run `appraisal rake spec`
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Brian Landau (Viget). See MIT_LICENSE for further details.

***

<a href="http://code.viget.com">
  <img src="http://code.viget.com/github-banner.png" alt="Code At Viget">
</a>

Visit [code.viget.com](http://code.viget.com) to see more projects from [Viget.](https://viget.com)
