defmodule OneSignal do
  def endpoint, do: "https://onesignal.com/api/v1"

  def new do
    %OneSignal.Param{}
  end

  def auth_header do
    %{"Authorization" => "Basic " <> fetch_api_key(), "Content-type" => "application/json"}
  end

  defp config do
    Application.get_env(:one_signal, OneSignal, %{})
  end

  defp fetch_api_key do
    config()[:api_key] || System.get_env("ONE_SIGNAL_API_KEY")
  end

  def fetch_app_id do
    config()[:app_id] || System.get_env("ONE_SIGNAL_APP_ID")
  end

  @spec json_library :: any
  def json_library do
    Application.get_env(:one_signal, :json_library, Poison)
  end
end
