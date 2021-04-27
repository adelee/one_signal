defmodule OneSignal do
  def endpoint, do: "https://onesignal.com/api/v1"

  def new do
    %OneSignal.Param{}
  end

  def auth_header do
    %{"Authorization" => "Basic " <> fetch_api_key(), "content-type" => "application/json"}
  end

  defp config do
    Application.get_env(:one_signal, OneSignal, %{})
  end

  defp fetch_api_key do
    config()[:api_key] || Application.get_env(:one_signal, :api_key) ||
      System.get_env("ONE_SIGNAL_API_KEY")
  end

  def fetch_app_id do
    config()[:app_id] || Application.get_env(:one_signal, :app_id) ||
      System.get_env("ONE_SIGNAL_APP_ID")
  end

  @spec json_library :: any
  def json_library() do
    Application.get_env(:one_signal, :json_library, Jason)
  end

  @spec http_client :: any
  def http_client() do
    Application.get_env(:one_signal, :http_client, OneSignal.HTTPClient.HTTPoison)
  end
end
