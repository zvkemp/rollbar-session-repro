# Be sure to restart your server when you modify this file.
#

class WarningMiddleware
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    Rollbar.configuration.enabled = true
    Rollbar.warn('foo')
    app.call(env)
  end
end

# Implementation doesn't really matter here; this wouldn't be
# hit until after the NoMethodError `id` for {}:Hash is raised
class CustomStore < ActionDispatch::Session::AbstractStore
  def get_session(env, session_id)
    [session_id, {}]
  end

  def set_session(*)
  end
end

# This also errors on using the default :cookie_store, but in a different way
# (attempts to load uninitialized options)
Rails.application.config.session_store CustomStore, key: '_rollbar_session_repro_session'

Rails.application.middleware.insert_before(
  CustomStore,
  WarningMiddleware
)
