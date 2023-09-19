import Config

config :banking,
  enable_user_request_delay: true,
  maximum_allowed_request: 10


import_config "#{config_env()}.exs"
