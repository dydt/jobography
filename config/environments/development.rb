Six470::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  config.action_mailer.default_url_options = {:host => 'localhost:3000'}
  
  Devise.setup do |config|
    config.omniauth :facebook, "154786507905802", "e812e0a5876c5812440648578b98aff7",
                        :scope => "offline_access,email,user_work_history,friends_work_history," +
                                  "user_location,friends_location"
    config.omniauth :linked_in, "3qcWfnMhLdFiHCHLhA9YuAudUL5_Di-IBkb-5A75J8VqjSzOk7J-Nz1nEhOhu6ge",
        "_fzN_wIEVqoMyWmnprovAFc5QJqEoD543JOby2tQ2Ftuk3CgYZegV8q5r5cNhwht"
  end
  
end

