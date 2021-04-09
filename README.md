# OneSignal

Elixir wrapper of [OneSignal](https://onesignal.com)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add one_signal to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [{:one_signal, "~> 0.0.6"}]
  end
```

3. Puts config your `config.exs`

```elixir
# deprecated
config :one_signal, OneSignal,
  api_key: "your api key",
  app_id: "your app id",

# new
config :one_signal,
  api_key: "your api key",
  app_id: "your app id",
  http_client: OneSignal.HTTPClient.HTTPoison, #default
  json_library: Jason #default


```

## Composable design, Data structure oriented

```elixir
  import OneSignal.Param
  OneSignal.new
  |> put_heading("Welcome!")
  |> put_message(:en, "Hello")
  |> put_message(:ja, "はろー")
  |> put_segment("Free Players")
  |> put_segment("New Players")
  |> notify
```
