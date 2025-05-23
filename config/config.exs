# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :commerce_front,
  ecto_repos: [CommerceFront.Repo]

# Configures the endpoint
config :commerce_front, CommerceFrontWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4vvlxoQtn0Dd2irSRa4d8QUAmkBWr+SaF8x3MbsR6CXEcQga/Vy5uvh01T9YlL89",
  render_errors: [view: CommerceFrontWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CommerceFront.PubSub,
  live_view: [signing_salt: "eHS1OdsC"]

config :commerce_front, CommerceFront.Repo,
  username: "postgres",
  password: "postgres",
  database: "commerce_front_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  timeout: 165_000

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :blue_potion,
  otp_app: "CommerceFront",
  repo: CommerceFront.Repo,
  contexts: ["Settings"],
  project: %{
    name: "CommerceFront",
    alias_name: "commerce_front",
    sname: "#{System.get_env("SNAME")}",
    vsn: "0.1.0"
  },
  server: %{
    url: "139.162.60.209",
    db_url: "127.0.0.1",
    username: "ubuntu",
    key: System.get_env("SERVER_KEY"),
    domain_name: "localhost"
  },
  stag_server: %{
    url: "192.53.172.101",
    db_url: "127.0.0.1",
    username: "ubuntu",
    key: System.get_env("STAG_SERVER_KEY"),
    domain_name: "localhost"
  }

config :commerce_front, CommerceFront.Scheduler,
  jobs: [
    {"05 0 * * 1", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}},
    {"05 0 * * 2", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}},
    {"05 0 * * 3", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}},
    {"05 0 * * 4", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}},
    {"05 0 * * 5", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}},
    {"05 0 * * 6", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}},
    {"05 0 * * 0", {CommerceFront, :daily_task, [Date.utc_today() |> Date.add(-1)]}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
