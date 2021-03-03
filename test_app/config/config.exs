use Mix.Config

config :rivulet, default_client: :"rivulet-client-#{System.get_env("HOSTNAME")}"
