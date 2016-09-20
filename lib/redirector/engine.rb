module Redirector
  class Engine < ::Rails::Engine
    config.redirector = ActiveSupport::OrderedOptions.new

    initializer "redirector.add_middleware", :after => 'build_middleware_stack' do |app|
      app.middleware.insert_before(Rack::Runtime, Redirector::Middleware)
    end

    initializer "redirector.apply_options" do |app|
      config = app.config.redirector

      Redirector.include_query_in_source   = config.include_query_in_source || false
      Redirector.preserve_query            = config.preserve_query || false
      Redirector.silence_sql_logs          = config.silence_sql_logs || false

      Redirector.use_environment_variables = config.use_environment_variables.nil? ? true : config.use_environment_variables
      Redirector.blacklisted_extensions    = config.blacklisted_extensions || []
    end
  end
end
